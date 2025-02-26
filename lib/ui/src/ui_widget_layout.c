﻿/*
 * lib/ui/src/ui_widget_layout.c
 *
 * Copyright (c) 2023-2024, Liu Chao <i@lc-soft.io> All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * This file is part of LCUI, distributed under the MIT License found in the
 * LICENSE.TXT file in the root directory of this source tree.
 */

// #define UI_DEBUG_ENABLED
#include <css/computed.h>
#include <ui/base.h>
#include <ui/events.h>
#include <ui/style.h>
#include "ui_debug.h"
#include "ui_block_layout.h"
#include "ui_flexbox_layout.h"
#include "ui_widget.h"
#include "ui_widget_style.h"
#include "ui_widget_box.h"

static void ui_widget_reflow_with_rule(ui_widget_t *w, ui_layout_rule_t rule)
{
	switch (w->computed_style.type_bits.display) {
	case CSS_DISPLAY_BLOCK:
	case CSS_DISPLAY_INLINE_BLOCK:
		ui_block_layout_reflow(w, rule);
		break;
	case CSS_DISPLAY_FLEX:
		ui_flexbox_layout_reflow(w, rule);
		break;
	case CSS_DISPLAY_NONE:
	default:
		break;
	}
}

/**
 * 重置布局相关属性，以让它们在布局时被重新计算
 * @param rule 父级组件所使用的布局规则
 */
void ui_widget_reset_layout(ui_widget_t *w, ui_layout_rule_t rule)
{
	css_computed_style_t *src = &w->specified_style;
	css_computed_style_t *dest = &w->computed_style;

	if ((rule & UI_LAYOUT_RULE_FIXED_WIDTH) == UI_LAYOUT_RULE_FIXED_WIDTH) {
		CSS_COPY_LENGTH(dest, src, width);
		CSS_COPY_LENGTH(dest, src, min_width);
		CSS_COPY_LENGTH(dest, src, max_width);
		CSS_COPY_LENGTH(dest, src, left);
		CSS_COPY_LENGTH(dest, src, right);
		CSS_COPY_LENGTH(dest, src, padding_left);
		CSS_COPY_LENGTH(dest, src, padding_right);
		CSS_COPY_LENGTH(dest, src, margin_left);
		CSS_COPY_LENGTH(dest, src, margin_right);
	}
	if ((rule & UI_LAYOUT_RULE_FIXED_HEIGHT) ==
	    UI_LAYOUT_RULE_FIXED_HEIGHT) {
		CSS_COPY_LENGTH(dest, src, height);
		CSS_COPY_LENGTH(dest, src, min_height);
		CSS_COPY_LENGTH(dest, src, max_height);
		CSS_COPY_LENGTH(dest, src, top);
		CSS_COPY_LENGTH(dest, src, bottom);
		CSS_COPY_LENGTH(dest, src, padding_top);
		CSS_COPY_LENGTH(dest, src, padding_bottom);
		CSS_COPY_LENGTH(dest, src, margin_top);
		CSS_COPY_LENGTH(dest, src, margin_bottom);
	}
}

void ui_widget_auto_reflow(ui_widget_t *w)
{
        float width, height;

        width = w->padding_box.width;
        height = w->padding_box.height;
        ui_widget_update_box_size(w);
        if (width != w->padding_box.width || height != w->padding_box.height) {
                ui_widget_reflow(w);
        }
}

void ui_widget_reflow(ui_widget_t *w)
{
	ui_layout_rule_t rule = UI_LAYOUT_RULE_MAX_CONTENT;
	ui_event_t ev = { .type = UI_EVENT_AFTERLAYOUT, .cancel_bubble = true };

	if (IS_CSS_FIXED_LENGTH(&w->computed_style, width)) {
		rule |= UI_LAYOUT_RULE_FIXED_WIDTH;
	}
	if (IS_CSS_FIXED_LENGTH(&w->computed_style, height)) {
		rule |= UI_LAYOUT_RULE_FIXED_HEIGHT;
	}
#ifdef UI_DEBUG_ENABLED
	{
		UI_WIDGET_STR(w, str);
		UI_DEBUG_MSG("%s: reflow begin, rule = %d", str, rule);
		ui_debug_msg_indent++;
	}
#endif

	ui_widget_reflow_with_rule(w, rule);
	ui_widget_post_event(w, &ev, NULL, NULL);
	ui_widget_add_state(w, UI_WIDGET_STATE_LAYOUTED);
#ifdef UI_DEBUG_ENABLED
	{
		ui_debug_msg_indent--;
		UI_WIDGET_STR(w, str);
		UI_DEBUG_MSG("%s: reflow end", str);
	}
#endif
}
