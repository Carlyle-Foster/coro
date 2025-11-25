package coroutines

import sl "selector"

STACK_CAPACITY :: 1024 * 16

// TODO: coroutines library probably does not work well in multithreaded environment
contexts: [dynamic]Context
dead:   [dynamic]int
current: int

active: [dynamic]int

selector: sl.Selector

g_waiting_coroutines := 0
g_reset_in_progress := false
