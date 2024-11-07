#include <unistd.h>
#include "QLog.hpp"
#include "QfrcSnap.hpp"

#if (INCLUDE_MODEL==1)
#include "QfrcModels.hpp"
#endif

#if AIFRC_PACKAGE
using namespace aifrclib;
#else
using namespace qfrclib;
#endif

int QfrcSnap::Init(
    const std::string modelPath, 
    const std::vector<std::string> inputNames, 
    const std::vector<std::string> outputNames, 
    QNpuType npuType, 
    QQuantizationType quantType, 
    int createSession)
{
    LOGD("[%s:%d] %s %s %s\n", __FUNCTION__, __LINE__, 
        modelPath.c_str(), inputNames[0].c_str(), outputNames[0].c_str());
    
    if(npuType == NPU_EDEN)
    {
        mSnapOption.mType = snap::ModelType::EDEN; 
        mSnapOption.compUnit = snap::ComputeUnit::NPU; 
        mSnapOption.execType = snap::ExecutionDataType::FLOAT32; 
        mSnapOption.dvfs_perf = snap::Dvfs::SUSTAINED_PERFORMANCE;
    }
    else if(npuType == NPU_MNP)
    {
        mSnapOption.mType = snap::ModelType::MNP; 
        mSnapOption.compUnit = snap::ComputeUnit::NPU; 
        mSnapOption.execType = snap::ExecutionDataType::FLOAT32; 
	    mSnapOption.snpe_buffer_type = snap::SnpeBufferType::UB_TF8;
        //mSnapOption.dataFormat = snap::DataFormat::NCHW;
        mSnapOption.enable_secure = false;
        //mSnapOption.debug_level = snap::DebugLevel::LEVEL4;
        mSnapOption.dvfs_perf = snap::Dvfs::HIGH_PERFORMANCE;
    }
    else 
    {
        mSnapOption.mType = snap::ModelType::SNPE; 
        mSnapOption.compUnit = snap::ComputeUnit::DSP; 
        mSnapOption.execType = snap::ExecutionDataType::FLOAT32; 
        mSnapOption.dvfs_perf = snap::Dvfs::SUSTAINED_PERFORMANCE;
    }
    
#if (INCLUDE_MODEL==1)
    LOGU("Loading model from library : %s", getModelName().c_str());
    mSnapOption.model_buffer_ptr = const_cast<uint8_t*>(getModelData());
    mSnapOption.model_buffer_len = getModelSize();
#else
    LOGU("Loading model from file : %s", modelPath.c_str());
    mSnapOption.model_file = modelPath;
    mSnapOption.model_name = modelPath;
#endif

    mSnapOption.inputNames.assign(inputNames.begin(), inputNames.end()); 
    mSnapOption.outputNames.assign(outputNames.begin(), outputNames.end()); 
    
    // mSnapOption.mean = {0.0, 0.0,}; 
    // mSnapOption.scale = {0.003921568859, 0.003921568859};
    // mSnapOption.stddev = {};

    mSnapOption.flag = snap::AddOptions::BALANCED_INFERENCE;
    mSnapOption.mode = snap::Mode::RELEASE;
    // mSnapOption.execOptMode = snap::ExecuteOptimizeMode::INOUTOPT;
    // mSnapOption.outputDataType = snap::ExecutionDataType::FLOAT32;
    // mSnapOption.input_shape = {{1, 544, 960, 8 }};
    // mSnapOption.allowReshape = true;

    if(createSession) 
    {
        mSnapSession = static_cast< snap::SNAP_SESSION *>(snap::CreateSnapSession());
        if(mSnapSession == nullptr)
        {
            LOGE("[%s:%d] mSnapSession is nullptr\n", __FUNCTION__, __LINE__);
            return snap::ERR;
        }
    }

    return snap::OK;
}

int QfrcSnap::Configure()
{
    std::vector<int32_t> shape;

    if(nullptr == mSnapSession) 
        return snap::ERR;

    snap::ErrCode ret = mSnapSession->Open(static_cast<const snap::SNAP_OPTION>(mSnapOption));
    LOGU("mSnapSession->Open ret %d", ret);
    if(snap::OK != ret)
    {
        LOGD("\tSNAP - mSnapSession->Open fails"); 
        return snap::ERR;
    }

    ret = mSnapSession->GetModelInputShape(0, &shape);
    if(snap::OK != ret)
    {
        LOGD("\tSNAP - mSnapSession->GetModelInputShape fails"); 
        return snap::ERR;
    }

    LOGD("shape : %d %d %d %d", shape[0], shape[1], shape[2], shape[3]);

    int batch = shape[0];
    int channel = shape[1];
    int height = shape[2];
    int width = shape[3];

    if(mSnapOption.mType == snap::ModelType::EDEN)
    {
        batch = shape[0];
        channel = shape[3];
        height = shape[1];
        width = shape[2];
        mInputBuffer.shape = {batch, channel, height, width};
        mInputBuffer.dataFormat = snap::DataFormat::NCHW;
        mInputBuffer.dataType = snap::DataBufferType::FLOAT32;
    }
    else if(mSnapOption.mType == snap::ModelType::MNP)
    {
        mInputBuffer.shape = {batch, channel, height, width};
        mInputBuffer.dataFormat = snap::DataFormat::NCHW;
        mInputBuffer.dataType = snap::DataBufferType::FLOAT32;
    }
    else
    {
        mInputBuffer.shape = {batch, height, width, channel};
        mInputBuffer.dataFormat = snap::DataFormat::NHWC;
        mInputBuffer.dataType = snap::DataBufferType::FLOAT32;
    }

    for(auto& name : mSnapOption.outputNames)
    {
        snap::TensorSize tensor;
        tensor.name = mSnapOption.outputNames.front();
        mOutputTensors.push_back(tensor);
    }
   
#if USE_IDL
    ret = mSnapSession->GetOutputSize(&mOutputTensors, snap::UcIntfType::HIDL);
    if(snap::OK != ret)
    {
        LOGD("\tSNAP - mSnapSession->GetOutputSize fails"); 
    }
#else
    // // when using snap_vndk, do not call GetOutputSize, fill the size manually
    // // (this suggestion is from Snap team)
    // if(mOutputTensors.size() > 0)
    // {
    //     mOutputTensors[0].size = 12533760; // = 272 * 480 * 24 * sizeof(float)
    // }    
    ret = mSnapSession->GetOutputSize(&mOutputTensors, snap::UcIntfType::VNDK);
    if(snap::OK != ret)
    {
        LOGD("\tSNAP - mSnapSession->GetOutputSize fails"); 
    }
#endif
    if(mOutputTensors.size() > 0)
        LOGD("output tensor : %s %d", mOutputTensors[0].name.c_str(),  mOutputTensors[0].size);
    
    return snap::OK;
}
int QfrcSnap::Shape(char dim)
{
    if(mInputBuffer.shape.size() <= 0)
    {
        LOGE("[%s:%d] cannot parse the shape because mInputBuffer.shape is empty", __FUNCTION__, __LINE__);
        return -1;
    }

    int char2idx[4] = {0, 3, 1, 2};
    int index = -1;

    if(mInputBuffer.dataFormat == snap::DataFormat::NCHW) 
    {
        char2idx[0] = 0;
        char2idx[1] = 1;
        char2idx[2] = 2;
        char2idx[3] = 3;
    }

    switch(dim) {
        case 'n': 
        case 'N': 
        case 'b': 
        case 'B':
            index = char2idx[0]; 
            break;

        case 'c': 
        case 'C':
            index = char2idx[1]; 
            break;

        case 'h': 
        case 'H':
            index = char2idx[2]; 
            break;

        case 'w': 
        case 'W':
            index = char2idx[3]; 
            break;
        
        default:
            return -1;
    }

    return mInputBuffer.shape[index];
}


size_t QfrcSnap::GetInputSize()
{
    size_t size = 1;
    
    switch(mInputBuffer.dataType) 
    {
        case snap::DataBufferType::INT8: 
            size = 1; 
            break;
        
        case snap::DataBufferType::INT16: 
            size = 2; 
            break;
        
        case snap::DataBufferType::FLOAT32:
        default:
            size = 4;
            break;
    }
    
    for(auto sz: mInputBuffer.shape)
    {
        size *= sz;
    }

    return size;
}


size_t QfrcSnap::GetOutputSize()
{
    if(mOutputTensors.size() > 0)
        return mOutputTensors[0].size;
    
    return -1;
}

int QfrcSnap::GetInputCount()
{
    return mSnapOption.inputNames.size();
}

int QfrcSnap::GetOutputCount()
{
    return mSnapOption.outputNames.size();
}

int QfrcSnap::AllocateAshmem(size_t in_size, int* out_unique_id)
{
    if(mSnapSession == nullptr) 
        return snap::ERR;

    return mSnapSession->AllocateAshmem(in_size, out_unique_id);
}

int QfrcSnap::GetBufferPtr(int in_unique_id, void* &out_buffer_to_write)
{
    if(mSnapSession == nullptr) 
        return snap::ERR;

    int err = mSnapSession->GetBufferPtr(in_unique_id, out_buffer_to_write);

    memMaps.insert(std::make_pair(in_unique_id, out_buffer_to_write));

    return err;
}

void* QfrcSnap::GetWorkingBuffer(int id, size_t size)
{
    if(mSnapSession == nullptr) 
        return nullptr;

    void* ptr = (void*)calloc(1, size);

    mWorkingBuffer.insert(std::make_pair(id, ptr));

    return ptr;
}

int QfrcSnap::Inference(std::vector<void*> inputs, std::vector<snap::DataBuffer> *outputs)
{
    snap::ErrCode err = snap::OK;
    std::vector<snap::DataBuffer> dataBuffers;
    
    if(mSnapSession == nullptr) 
        return snap::ERR;

    for(auto input : inputs) {
        snap::DataBuffer buffer = mInputBuffer;
        buffer.data = (void*)input; 
        dataBuffers.push_back(buffer);
    }
    
    err = mSnapSession->Execute(dataBuffers, outputs);

    LOGE("Inference : %p %p %d %d", inputs.at(0), outputs, (int)err, (*outputs)[0].dataType);

    return err;
}


int QfrcSnap::Inference(std::vector<int> inputs, std::vector<int> *outputs)
{
    snap::ErrCode err = snap::OK;
    std::vector<snap::DataBufferOpt> sharedIns;
    std::vector<snap::DataBufferOpt> sharedOuts;

    LOGE("Inference Called : %d %d %d", inputs.front(), inputs.back(), (*outputs).back());
    
    if(mSnapSession == nullptr) 
        return snap::ERR;

    for(auto id : inputs) {
        
        auto item = memMaps.find(id);
        
        snap::DataBufferOpt buffer(
            item->second,
            mInputBuffer.shape,
            mInputBuffer.dataType,
            mInputBuffer.dataFormat,
            id, 
            {}
        );
        buffer.bufferId = id; 
        sharedIns.push_back(buffer);
    }

    for(auto id : *outputs) {
        
        auto item = memMaps.find(id);
        
        snap::DataBufferOpt buffer{};

        buffer.data = item->second;
        buffer.dataFormat = mInputBuffer.dataFormat;
        buffer.dataType = mInputBuffer.dataType;
        buffer.bufferId = id;

        sharedOuts.push_back(buffer);
    }
    
    err = mSnapSession->Execute(sharedIns, &sharedOuts);

    LOGE("Inference Called : %d %lu", err, sharedOuts.size());
    // LOGE("Inference : %p %p %d %d", inputs.at(0), outputs, (int)err, (*outputs)[0].dataType);

    return err;
}


int QfrcSnap::Inference(std::vector<snap::DataBufferOpt> inputs, std::vector<snap::DataBufferOpt> *outputs)
{
    snap::ErrCode err = snap::OK;
    
    if(mSnapSession == nullptr) 
        return snap::ERR;
    
    err = mSnapSession->Execute(inputs, outputs);

    LOGE("Inference : %d %p %d %d", inputs.at(0).bufferId, outputs, (int)err, (*outputs)[0].dataType);

    return err;
}

QfrcSnap::~QfrcSnap() 
{
    if(mSnapSession != nullptr) 
    {
        snap::ErrCode err = mSnapSession->Close();

        LOGE("QfrcSnap::cleanup mSnapSession->Close() result : %d", err);

        if(err == snap::OK)
        {
            err = snap::DestroySnapSession(mSnapSession);
            LOGE("QfrcSnap::cleanup snap::DestroySnapSession(mSnapSession) result : %d", err);
        }
        
        mSnapSession = nullptr;
    }

    mOutputTensors.clear();

    for(auto& p : mWorkingBuffer)
    {
        if(p.second != nullptr)
            free(p.second);
    }

    mWorkingBuffer.clear();

    memMaps.clear();
}
