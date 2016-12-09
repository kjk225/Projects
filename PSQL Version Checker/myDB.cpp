#include <iostream>
#include <libpq-fe.h>

using namespace std;

//exit nicely if the connection to database fails
static void exit_nicely(PGconn *conn)
{
    PQfinish(conn);
    exit(1);
}

int main(int argc, char* argv[])
{
    PGconn *conn;
    const char *conninfo;

    /*
     * If the user supplies a parameter on the command line, use it as the
     * conninfo string; otherwise default to setting dbname=p and using
     * environment variables or defaults for all other connection parameters.
     */
    if (argc > 1) {conninfo = argv[1];}
    else conninfo = "dbname = postgres";

    conn = PQconnectdb(conninfo);

    if (PQstatus(conn) == CONNECTION_BAD) {
        fprintf(stderr, "Connection to database failed: %s", PQerrorMessage(conn));
        exit_nicely(conn);
    }

    int version = PQserverVersion(conn);
    printf("Your server is running PostgreSQL version: %d\n", version);

    if (version < 90601) { fprintf(stderr, "This is not the latest version!\n"); }
    if (version > 90601) { fprintf(stderr, "Version cannot be determined!\n"); }
    fprintf(stderr, "This the latest version!\n");

    PQfinish(conn);

   return 0;
}

