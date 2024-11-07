//==============================================================================
//
//  Copyright (c) 2021-2022 Quramsoft. Fingram.
//  All Rights Reserved.
//  Confidential and Proprietary - Quramsoft.
//  Created by ks.yoo 2022-01-20
//
//==============================================================================
#ifndef QFRCSNAP_H
#define QFRCSNAP_H

#include "QfrcINpu.hpp"

#define SNAP_OPTION SnapOptionsV4
#define SNAP_SESSION SnapSessionVx

#if AIFRC_PACKAGE
namespace aifrclib {
#else
namespace qfrclib {
#endif
class QfrcSnap : public QfrcINpu {

public:
    QfrcSnap() {}

    ~QfrcSnap();

    int Init(
        const std::string modelPath, 
        const std::vector<std::string> inputNames, 
        const std::vector<std::string> outputNames, 
        QNpuType npuType, 
        QQuantizationType quantType, 
        int createSession
    );
    
    int Configure();
    int Inference(std::vector<void*> inputs, std::vector<snap::DataBuffer> *outputs);
    int Inference(std::vector<int> inputs, std::vector<int> *outputs);
    int Inference(std::vector<snap::DataBufferOpt> inputs, std::vector<snap::DataBufferOpt> *outputs);

    size_t GetInputSize();
    size_t GetOutputSize();
    int Shape(char dim);
    int GetInputCount();
    int GetOutputCount();
    int AllocateAshmem(size_t in_size, int* out_unique_id);
    int GetBufferPtr(int in_unique_id, void* &out_buffer_to_write);
    void* GetWorkingBuffer(int id, size_t size);
    void GetEncoding(float *min, float *max) {};

private:
    
    snap::SNAP_OPTION mSnapOption;
    snap::SNAP_SESSION *mSnapSession = nullptr;
    snap::DataBuffer mInputBuffer;
    std::vector<snap::TensorSize> mOutputTensors;

    std::map<int, void*> memMaps{};
    std::map<int, void*> mWorkingBuffer{};
};

} //end of namespace qfrclib

#endif
