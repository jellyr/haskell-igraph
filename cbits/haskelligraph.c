#ifndef HASKELL_IGRAPH
#define HASKELL_IGRAPH

#include <igraph/igraph.h>

igraph_strvector_t* igraph_strvector_new(long int size)
{
  igraph_strvector_t* vector = (igraph_strvector_t*) malloc (sizeof (igraph_strvector_t));
  igraph_strvector_init(vector, size);
  return vector;
}

char** igraph_strvector_get_(igraph_strvector_t* s, long int i)
{
  char** x = (char**) malloc (sizeof(char*));
  igraph_strvector_get(s, i, x);
  return x;
}

igraph_matrix_t* igraph_matrix_new(long int nrow, long int ncol)
{
  igraph_matrix_t* matrix = (igraph_matrix_t*) malloc (sizeof (igraph_matrix_t));
  igraph_matrix_init(matrix, nrow, ncol);
  return matrix;
}

igraph_t* igraph_new(igraph_integer_t n, igraph_bool_t directed)
{
  igraph_t* graph = (igraph_t*) malloc (sizeof (igraph_t));
  igraph_empty(graph, n, directed);
  return graph;
}

igraph_integer_t igraph_get_eid_(igraph_t* graph, igraph_integer_t pfrom, igraph_integer_t pto,
           igraph_bool_t directed, igraph_bool_t error)
{
  igraph_integer_t eid;
  igraph_get_eid(graph, &eid, pfrom, pto, directed, error);
  return eid;
}

igraph_t* igraph_full_(igraph_integer_t n, igraph_bool_t directed, igraph_bool_t loops)
{
  igraph_t* graph = (igraph_t*) malloc (sizeof (igraph_t));
  igraph_full(graph, n, directed, loops);
  return graph;
}

void haskelligraph_init()
{
  /* attach attribute table */
  igraph_i_set_attribute_table(&igraph_cattribute_table);
}

igraph_arpack_options_t* igraph_arpack_new()
{
  igraph_arpack_options_t *arpack = (igraph_arpack_options_t*) malloc(sizeof(igraph_arpack_options_t));
  igraph_arpack_options_init(arpack);
  return arpack;
}

void igraph_arpack_destroy(igraph_arpack_options_t* arpack)
{
  if (arpack)
    free(arpack);
  arpack = NULL;
}

igraph_vs_t* igraph_vs_new() {
  igraph_vs_t* vs = (igraph_vs_t*) malloc (sizeof (igraph_vs_t));
  return vs;
}

#endif