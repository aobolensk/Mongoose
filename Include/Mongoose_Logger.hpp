/**
 * @file Mongoose_Logger.hpp
 * @author Scott Kolodziej
 * @date 23 Sep 2016
 * @brief Centralized debug and timing manager
 *
 * @details For debug and timing information to be displayed via stdin. This system
 * allows this information to be displayed (or not) without recompilation.
 * Timing inforation for different *portions of the library are also managed 
 * here with a tic/toc pattern.
 */

#ifndef Mongoose_Logger_hpp
#define Mongoose_Logger_hpp

#include <string>
#include <time.h> 
#include <iostream>

namespace Mongoose
{

typedef enum DebugType
{
    None = 0,
    Error = 1,
    Warn = 2,
    Info = 4,
    Test = 8,
    All = 15
} DebugType;

typedef enum TimingType
{
    MatchingTiming = 0,
    CoarseningTiming = 1,
    RefinementTiming = 2,
    FMTiming = 3,
    QPTiming = 4,
    IOTiming = 5
} TimingType;

class Logger
{
  private:
    static int debugLevel;
    static bool timingOn;
    static clock_t clocks[6];
    static float times[6];

  public:
    static inline void log(DebugType debugType, std::string output);
    static inline void tic(TimingType timingType);
    static inline void toc(TimingType timingType);
    static inline float getTime(TimingType timingType);
    static void setDebugLevel(int debugType);
    static void setTimingFlag(bool tFlag);
    static void printTimingInfo();
};

/** 
 * @brief Log information at a specific log level.
 * 
 * Given a debugType (Error, Warn, Info, or Test), the log function will
 * route the output string to stdin (if the appropriate log level is activated).
 * For performance, this is an inline function, and a single bitwise AND
 * operation is used to determine if the output string should be displayed.
 *
 * @param debugType the logging level this message belongs to (either Error, 
 *    Warn, Info, or Test).
 * @param output the string to be displayed if the appropriate logging level
 *    is enabled.
 */ 
inline void Logger::log(DebugType debugType, std::string output)
{
    if (debugType & debugLevel)
    {
        std::cout << output << "\n";
    }
}

/** 
 * @brief Start a timer for a given type/part of the code.
 * 
 * Given a timingType (MatchingTiming, CoarseningTiming, RefinementTiming, 
 * FMTiming, QPTiming, or IOTiming), a clock is started for that computation.
 * The general structure is to call tic(IOTiming) at the beginning of an I/O
 * operation, then call toc(IOTiming) at the end of the I/O operation.
 *
 * Note that problems can occur and timing results may be inaccurate if a tic
 * is followed by another tic (or a toc is followed by another toc).
 *
 * @param timingType The portion of the library being timed (MatchingTiming, 
 *   CoarseningTiming, RefinementTiming, FMTiming, QPTiming, or IOTiming).
 *
 * @see toc()
 * @see getTime()
 */ 
inline void Logger::tic(TimingType timingType)
{
    if (timingOn)
    {
        clocks[timingType] = clock();
    }
}

/** 
 * @brief Stop a timer for a given type/part of the code.
 * 
 * Given a timingType (MatchingTiming, CoarseningTiming, RefinementTiming, 
 * FMTiming, QPTiming, or IOTiming), a clock is stopped for that computation.
 * The general structure is to call tic(IOTiming) at the beginning of an I/O
 * operation, then call toc(IOTiming) at the end of the I/O operation.
 *
 * Note that problems can occur and timing results may be inaccurate if a tic
 * is followed by another tic (or a toc is followed by another toc).
 *
 * @param timingType The portion of the library being timed (MatchingTiming, 
 *   CoarseningTiming, RefinementTiming, FMTiming, QPTiming, or IOTiming).
 *
 * @see tic()
 * @see getTime()
 */ 
inline void Logger::toc(TimingType timingType)
{
    if (timingOn)
    {
        times[timingType] += ((float)(clock() - clocks[timingType])) / CLOCKS_PER_SEC;
    }
}

/** 
 * @brief Get the time recorded for a given timing type.
 * 
 * Retreive the total clock time for a given timing type (MatchingTiming, 
 * CoarseningTiming, RefinementTiming, FMTiming, QPTiming, or IOTiming).
 *
 * @param timingType The portion of the library being timed (MatchingTiming, 
 *   CoarseningTiming, RefinementTiming, FMTiming, QPTiming, or IOTiming).
 *
 * @see tic()
 * @see toc()
 */ 
inline float Logger::getTime(TimingType timingType)
{
    return times[timingType];
}

} // end namespace Mongoose

#endif