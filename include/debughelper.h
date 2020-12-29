#pragma once

#ifdef __cplusplus
#define EXTERN_C_BEGIN \
    extern "C"         \
    {
#define EXTERN_C_END }
#else
#define EXTERN_C_BEGIN
#define EXTERN_C_END
#endif

#ifdef DEBUG
#include <fcntl.h>
#include <stdbool.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include <json.h>

EXTERN_C_BEGIN
static void dh_redir_output(const char *outfile, const char *errfile)
{
    int fdout = open(outfile, O_RDWR | O_CREAT | O_APPEND, 0666);
    int fderr = open(errfile, O_RDWR | O_CREAT | O_APPEND, 0666);
    // make stdout go to file
    dup2(fdout, 1);
    // make stderr go to file
    dup2(fderr, 2);

    // fd no longer needed - the dup'ed handles are sufficient
    close(fdout);
    close(fderr);
}

static void debug_helper_setup(int argc, char **argv)
{
    if (argc < 2)
    {
        return;
    }
    json_object *json, *parameters, *param_wait_for_debugger;
    json = json_tokener_parse(argv[1]);
    if (json == NULL)
    {
        return;
    }
    if (!json_object_object_get_ex(json, "parameters", &parameters))
    {
        goto free_json;
    }
    if (!json_object_object_get_ex(parameters, "wait_for_debugger", &param_wait_for_debugger))
    {
        goto free_params;
    }
    if (strcmp("true", json_object_get_string(param_wait_for_debugger)) == 0)
    {
        raise(SIGSTOP);
    }
    json_object_put(param_wait_for_debugger);
free_params:
    json_object_put(parameters);
free_json:
    json_object_put(json);
}
EXTERN_C_END
#define DEBUG_HELPER(argc, argv) debug_helper_setup(argc, argv)
#define REDIR_STDOUT(filename) dh_redir_output("/tmp/" filename ".out.log", "/tmp/" filename ".err.log")
#else
#define DEBUG_HELPER(argc, argv)
#define REDIR_STDOUT(filename)
#endif