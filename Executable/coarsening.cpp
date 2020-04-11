#include "Mongoose_Coarsening.hpp"
#include "Mongoose_IO.hpp"
#include "Mongoose_Logger.hpp"

using namespace Mongoose;

int main(int argn, const char **argv)
{
    SuiteSparse_start();

    // Set Logger to report only Error messages
    Logger::setDebugLevel(Error);

    // Turn timing information on
    Logger::setTimingFlag(true);

    if (argn < 2 || argn > 2)
    {
        // Wrong number of arguments - return error
        LogError("Usage: coarsening <MM-input-file.mtx> [output-file]");
        return EXIT_FAILURE;
    }

    // Read in input file name
    std::string inputFile = std::string(argv[1]);

    EdgeCut_Options *options = EdgeCut_Options::create();
    if (!options)
    {
        // Ran out of memory
        LogError("Error creating Options struct");
        return EXIT_FAILURE;
    }

    Graph *graph = read_graph(inputFile);

    if (!graph)
    {
        // Ran out of memory or problem reading the graph from file
        LogError("Error reading Graph from file");
        return EXIT_FAILURE;
    }

    EdgeCutProblem *ecp = EdgeCutProblem::create(graph);
    if (!graph)
    {
        LogError("Error creating EdgeCutProblem");
        return EXIT_FAILURE;
    }
    EdgeCutProblem *result = ecp;
    while (result->n >= 256) {
        fprintf(stderr, "Number of vertexes: %ld\n", result->n);
        match(result, options);
        result = coarsen(result, options);
        if (!result)
        {
            LogError("Error coarsening");
            return EXIT_FAILURE;
        }
    }
    fprintf(stderr, "Final number of vertexes: %ld\n", result->n);

    write_graph(result);
    return EXIT_SUCCESS;
}
