﻿/*
 * lib/ui-router/include/ui_router/types.h
 *
 * Copyright (c) 2023-2024, Liu Chao <i@lc-soft.io> All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * This file is part of LCUI, distributed under the MIT License found in the
 * LICENSE.TXT file in the root directory of this source tree.
 */

#ifndef LIB_UI_ROUTER_INCLUDE_UI_ROUTER_TYPES_H
#define LIB_UI_ROUTER_INCLUDE_UI_ROUTER_TYPES_H

#include <stdbool.h>
#include <yutil.h>

typedef struct strmap_t strmap_t;

typedef struct strmap_item_t {
        char *key;
        char *value;
        list_node_t node;
} strmap_item_t;

typedef struct strmap_iterator_t {
        size_t index;
        strmap_item_t *item, *next_item;
} strmap_iterator_t;

typedef list_t router_linkedlist_t;
typedef list_node_t router_linkedlist_node_t;
typedef struct router_t router_t;
typedef struct router_location_t router_location_t;
typedef struct router_config_t router_config_t;
typedef struct router_route_t router_route_t;
typedef struct router_route_record_t router_route_record_t;
typedef struct router_history_t router_history_t;
typedef struct router_watcher_t router_watcher_t;
typedef struct router_matcher_t router_matcher_t;
typedef struct router_resolved_t router_resolved_t;
typedef void (*router_callback_t)(void *, const router_route_t *,
                                  const router_route_t *);

#endif
