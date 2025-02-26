﻿/*
 * lib/pandagl/src/line.c
 *
 * Copyright (c) 2023-2024, Liu Chao <i@lc-soft.io> All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * This file is part of LCUI, distributed under the MIT License found in the
 * LICENSE.TXT file in the root directory of this source tree.
 */

#include <pandagl.h>

void pd_canvas_draw_horizontal_line(pd_canvas_t *canvas, pd_color_t color,
				    int size, pd_pos_t start, int len)
{
	int y, x;
	pd_rect_t area;
	pd_canvas_t *des;

	des = pd_canvas_get_quote_source(canvas);
	pd_canvas_get_quote_rect(canvas, &area);
	start.x = area.x + start.x;
	start.y = area.y + start.y;

	if (start.x < area.x) {
		len -= (area.x - start.x);
		start.x = area.x;
	}
	if (len > area.x + area.width) {
		len = area.x + area.width;
	}
	if (start.y < area.y) {
		size -= (area.y - start.y);
		start.y = area.y;
	}
	if (start.y + size > area.y + area.height) {
		size = area.y + area.height - start.y;
	}
	if (des->color_type == PD_COLOR_TYPE_ARGB) {
		pd_color_t *pPixel, *pRowPixel;
		pRowPixel = des->argb + start.y * des->width + start.x;
		for (y = 0; y < size; ++y) {
			pPixel = pRowPixel;
			for (x = 0; x < len; ++x) {
				pPixel->b = color.blue;
				pPixel->g = color.green;
				pPixel->r = color.red;
				pPixel->a = 255;
				++pPixel;
			}
			pRowPixel += des->width;
		}
	} else {
		uint8_t *pByte, *pRowByte;
		pRowByte =
		    des->bytes + start.y * des->bytes_per_row + start.x * 3;
		for (y = 0; y < size; ++y) {
			pByte = pRowByte;
			for (x = 0; x < len; ++x) {
				*pByte++ = color.blue;
				*pByte++ = color.green;
				*pByte++ = color.red;
			}
			pRowByte += des->bytes_per_row;
		}
	}
}

void pd_canvas_draw_vertical_line(pd_canvas_t *canvas, pd_color_t color,
				  int size, pd_pos_t start, int len)
{
	int y, x;
	pd_rect_t area;
	pd_canvas_t *des;

	des = pd_canvas_get_quote_source(canvas);
	pd_canvas_get_quote_rect(canvas, &area);
	start.x = area.x + start.x;
	start.y = area.y + start.y;

	if (start.x < area.x) {
		size -= (area.x - start.x);
		start.x = area.x;
	}
	if (start.x + size > area.x + area.width) {
		size = area.x + area.width - start.x;
	}

	if (start.y < area.y) {
		len -= (area.y - start.y);
		start.y = area.y;
	}
	if (start.y + len > area.y + area.height) {
		len = area.y + area.height - start.y;
	}

	if (des->color_type == PD_COLOR_TYPE_ARGB) {
		pd_color_t *pPixel, *pRowPixel;
		pRowPixel = des->argb + start.y * des->width + start.x;
		for (y = 0; y < len; ++y) {
			pPixel = pRowPixel;
			for (x = 0; x < size; ++x) {
				pPixel->b = color.blue;
				pPixel->g = color.green;
				pPixel->r = color.red;
				pPixel->a = 255;
				++pPixel;
			}
			pRowPixel += des->width;
		}
	} else {
		uint8_t *pByte, *pRowByte;
		pRowByte =
		    des->bytes + start.y * des->bytes_per_row + start.x * 3;
		for (y = 0; y < len; ++y) {
			pByte = pRowByte;
			for (x = 0; x < size; ++x) {
				*pByte++ = color.blue;
				*pByte++ = color.green;
				*pByte++ = color.red;
			}
			pRowByte += des->bytes_per_row;
		}
	}
}
