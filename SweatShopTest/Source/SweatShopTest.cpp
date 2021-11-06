////////////////////////////////////////////////////////////////////////////////
///
/// SweatShopTest.cpp
/// ----------------
///
/// Copyright (c) 2017 - 2020. Microblink Ltd. All rights reserved.
///
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
#include <Sweater/SweatShop.hpp>

#include <gtest/gtest.h>

#include <array>
#include <cstdio>
#include <numeric>
#include <thread>
//------------------------------------------------------------------------------

using iterations_t = boost::sweater::shop::iterations_t;

TEST( SweatShopTest, spreadTheSweat )
{
    constexpr auto numElems = 30000000U;

    std::vector< unsigned int > arr;
    arr.resize( numElems );
    auto worker = [ & ]( iterations_t startIteration, iterations_t stopIteration ) noexcept
    {
        for ( auto i = startIteration; i < stopIteration; ++i )
        {
            arr[ i ] += 10;
        }
    };
    MB::ThreadPool::sweatShop.spread_the_sweat( numElems, worker );
    auto result = std::accumulate( arr.begin(), arr.end(), 0U );
    ASSERT_EQ( result, numElems * 10U );
}
