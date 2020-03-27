// ----------------------------------------------------------------------------
// Gunrock -- Fast and Efficient GPU Graph Library
// ----------------------------------------------------------------------------
// This source code is distributed under the terms of LICENSE.TXT
// in the root directory of this source distribution.
// ----------------------------------------------------------------------------

/**
 * @file
 * dyn.cuh
 *
 * @brief DYN (Dynamic) Graph Data Structure
 */
#pragma once

#include <gunrock/graph/dynamic_graph/dynamic_graph.cuh>
#include <gunrock/graph/dynamic_graph/dynamic_graph_base.cuh>

namespace gunrock {
namespace graph {


template<
    typename VertexT,
    typename SizeT,
    typename ValueT,
    GraphFlag FLAG,
    unsigned int cudaHostRegisterFlag>
struct Dyn<VertexT, SizeT, ValueT, FLAG, cudaHostRegisterFlag, true, true> : public DynamicGraphBase<VertexT, SizeT, ValueT, FLAG> {

    //using PairT = uint2;

    template <typename PairT>
    cudaError_t InsertEdgesBatch(util::Array1D<SizeT, PairT>& edges,
                                 util::Array1D<SizeT, ValueT>& vals,
                                 SizeT batchSize){

        //make sure everything is on the GPU
        edges.Move(util::HOST, util::DEVICE);
        vals.Move(util::HOST, util::DEVICE);

        this->dynamicGraph.InsertEdgesBatch(edges.GetPointer(util::DEVICE),
                                            vals.GetPointer(util::DEVICE),
                                            batchSize,
                                            !this->is_directed);
        return cudaSuccess;
    }

    template <typename CsrT_in>
    cudaError_t FromCsr(
        CsrT_in &csr,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        this->is_directed = csr.directed;
        this->dynamicGraph.BulkBuildFromCsr(csr.row_offsets.GetPointer(util::HOST),
                                            csr.column_indices.GetPointer(util::HOST),
                                            csr.edge_values.GetPointer(util::HOST),
                                            csr.nodes,
                                            csr.directed, //input graph must respect that. no checks for it is done inside
                                            csr.node_values.GetPointer(util::HOST));
        return cudaSuccess;
    }


    template <typename CsrT_in>
    cudaError_t ToCsr(
        CsrT_in &csr,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        this->dynamicGraph.ToCsr(csr.row_offsets.GetPointer(util::DEVICE),
                                 csr.column_indices.GetPointer(util::DEVICE),
                                 csr.edge_values.GetPointer(util::DEVICE),
                                 csr.nodes,
                                 csr.edges,
                                 csr.node_values.GetPointer(util::DEVICE));
        return cudaSuccess;
    }


    template <typename GraphT>
    cudaError_t FromCsrAndCoo(
        GraphT &graph_in,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        return cudaSuccess;
    }
};




template<
    typename VertexT,
    typename SizeT,
    typename ValueT,
    GraphFlag FLAG,
    unsigned int cudaHostRegisterFlag>
struct Dyn<VertexT, SizeT, ValueT, FLAG, cudaHostRegisterFlag, false, true> {

    template <typename PairT>
    cudaError_t InsertEdgesBatch(util::Array1D<SizeT, PairT> src, 
                                 util::Array1D<SizeT, ValueT> vals,
                                 SizeT batchSize,
                                 util::Location target = util::DEVICE){

        return cudaSuccess;
    }
    template <typename CsrT_in>
    cudaError_t FromCsr(
        CsrT_in &csr,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        return cudaSuccess;
    }
 
    template <typename GraphT>
    cudaError_t FromCsrAndCoo(
        GraphT &graph_in,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        return cudaSuccess;
    }   


     template <typename CsrT_in>
    cudaError_t ToCsr(
        CsrT_in &csr,
        util::Location target = util::LOCATION_DEFAULT,
        cudaStream_t stream = 0,
        bool quiet = false)
    {
        return cudaSuccess;
    }
   

    cudaError_t Release(util::Location target = util::LOCATION_ALL)
    {
        return cudaSuccess;
    }

};


} // namespace graph
} // namespace gunrock
