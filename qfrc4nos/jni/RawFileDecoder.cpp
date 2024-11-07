#include "RawFileDecoder.hpp"

#include <cstring> // for strerror
#include <cerrno>  // for errno

using namespace std;

#include <android/log.h>
#define  LOG_TAG    "RawFileDecoder"
#ifdef LOGD
#undef LOGD
#endif
#define  LOGD(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
static void LOGU(const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    //vprintf(fmt, args);
    vfprintf(stderr, fmt, args);
    va_end(args);
    fprintf(stderr, "\n");
};

RawFileDecoder::~RawFileDecoder()
{
	if (!m_ifs.is_open())
        m_ifs.close();
}

void RawFileDecoder::init(
    string filepath, 
    int w,
    int h,
    int bitsPerPixel,
    int validBits
)
{
    m_w = w;
    m_h = h;
    m_bitsPerPixel = bitsPerPixel;
    m_validBits = validBits;

    m_chunkSize = w * h * ((bitsPerPixel+7)/8) * 1.5;

    LOGU("RawFileDecoder::init m_chunkSize %d x %d x %d x 1.5 = %d", w, h, ((bitsPerPixel+7)/8), m_chunkSize);

    openFile(filepath);
}

bool RawFileDecoder::openFile(string filepath)
{
    m_ifs.open(filepath, ios::binary);
	if (!m_ifs.is_open()) {
		std::cerr << "Error opening the file." << std::endl;
		std::cerr << "Error code: " << strerror(errno) << std::endl;
		return false;
	}
    return true;
}

bool RawFileDecoder::decodeFrame(uint8_t **buffer, size_t *frameBufferSize)
{
	if (!m_ifs.is_open() || m_ifs.eof())
		return false;
        
    if(buffer == nullptr)
    {
        LOGU("RawFileDecoder::decodeFrame buffer initialize");
        *buffer = new uint8_t[m_chunkSize];
    }
    
    std::vector<char> t(m_chunkSize);
    m_ifs.read(t.data(), m_chunkSize);
    streamsize bytesRead = m_ifs.gcount();
    memcpy(*buffer, t.data(), m_chunkSize);
    
    *frameBufferSize = bytesRead;
    LOGU("decodeFrame bytesRead %d m_chunkSize %d ret %d", bytesRead, m_chunkSize, bytesRead == m_chunkSize);
    return bytesRead == m_chunkSize;
}
