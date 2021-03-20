#include <Sweater/SweatShop.hpp>

//------------------------------------------------------------------------------
namespace MB::ThreadPool
{
//------------------------------------------------------------------------------

#ifdef __GNUC__
__attribute__(( weak, cold ))
#endif // __GNUC__
void configure_for_hardware( [[ maybe_unused ]] boost::sweater::shop & __restrict shop ) noexcept
{
#if BOOST_SWEATER_CALLER_BOOST
    shop.caller_boost     =  0;
    shop.caller_boost_max = 12;
#endif  // BOOST_SWEATER_CALLER_BOOST
#if BOOST_SWEATER_SPIN_BEFORE_SUSPENSION
    shop.worker_spin_count = 800;
#if BOOST_SWEATER_USE_CALLER_THREAD
    shop.caller_spin_count = 800;
#endif // BOOST_SWEATER_USE_CALLER_THREAD
#endif // BOOST_SWEATER_SPIN_BEFORE_SUSPENSION
}

struct ConfiguredSweatShop
{
    ConfiguredSweatShop() noexcept { configure_for_hardware( shop ); }

    boost::sweater::shop shop;
} configuredSweatShop;

boost::sweater::shop & sweatShop{ configuredSweatShop.shop };

//------------------------------------------------------------------------------
} // namespace namespace MB::ThreadPool
//------------------------------------------------------------------------------
