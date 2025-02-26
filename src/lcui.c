﻿/*
 * src/lcui.c
 *
 * Copyright (c) 2023-2024, Liu Chao <i@lc-soft.io> All rights reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * This file is part of LCUI, distributed under the MIT License found in the
 * LICENSE.TXT file in the root directory of this source tree.
 */

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <LCUI/config.h>
#include <LCUI/app.h>
#include <ptk.h>
#include <ui.h>
#include <worker.h>
#include <thread.h>

#define LCUI_WORKER_NUM 4

/** LCUI 应用程序数据 */
static struct lcui_app_t {
        ptk_steptimer_t timer;
        worker_t *main_worker;
        worker_t *workers[LCUI_WORKER_NUM];
        int worker_next;
} lcui_app;

const char *lcui_get_version(void)
{
        return PACKAGE_VERSION;
}

bool lcui_post_task(worker_task_t *task)
{
        if (!lcui_app.main_worker) {
                return false;
        }
        worker_post_task(lcui_app.main_worker, task);
        return true;
}

bool lcui_post_simple_task(worker_callback_t callback, void *arg1, void *arg2)
{
        worker_task_t task = { 0 };
        task.arg[0] = arg1;
        task.arg[1] = arg2;
        task.callback = callback;
        return lcui_post_task(&task);
}

void lcui_post_async_task(worker_task_t *task, int worker_id)
{
        if (worker_id < 0) {
                if (lcui_app.worker_next >= LCUI_WORKER_NUM) {
                        lcui_app.worker_next = 0;
                }
                worker_id = lcui_app.worker_next;
                lcui_app.worker_next += 1;
        }
        if (worker_id >= LCUI_WORKER_NUM) {
                worker_id = 0;
        }
        worker_post_task(lcui_app.workers[worker_id], task);
}

uint32_t lcui_get_fps(void)
{
        return lcui_app.timer.frames_per_second;
}

void lcui_set_frame_rate_cap(unsigned rate_cap)
{
        if (rate_cap > 0) {
                lcui_app.timer.target_elapsed_time = 1000 / rate_cap;
                lcui_app.timer.is_fixed_time_step = true;
        } else {
                lcui_app.timer.is_fixed_time_step = false;
        }
}

static void lcui_app_on_tick(ptk_steptimer_t *timer, void *data)
{
        lcui_render_ui();
        app_present();
}

static int lcui_dispatch_app_event(ptk_event_t *e)
{
        if (e->type == PTK_EVENT_QUIT) {
                return 0;
        }
        worker_run_task(lcui_app.main_worker);
        lcui_dispatch_ui_event(e);
        lcui_update_ui();
        ptk_steptimer_tick(&lcui_app.timer, lcui_app_on_tick, NULL);
        return 0;
}

int lcui_process_events(ptk_process_events_option_t option)
{
        return ptk_process_native_events(option);
}

void lcui_init_app(void)
{
        int i;
        logger_log(LOGGER_LEVEL_INFO,
                   "LCUI (LC's UI) version " PACKAGE_VERSION "\n"
                   "Build at "__DATE__
                   " - "__TIME__
                   "\n"
                   "Copyright (C) 2012-2024 Liu Chao <root@lc-soft.io>.\n"
                   "This is open source software, licensed under MIT. \n"
                   "See source distribution for detailed copyright notices.\n"
                   "To learn more, visit http://www.lcui.org.\n\n");

        lcui_reset_settings();
        ptk_steptimer_init(&lcui_app.timer);
        lcui_app.main_worker = worker_create();
        for (i = 0; i < LCUI_WORKER_NUM; ++i) {
                lcui_app.workers[i] = worker_create();
                worker_run_async(lcui_app.workers[i]);
        }
        lcui_app.timer.target_elapsed_time = 0;
}

void lcui_destroy_app(void)
{
        int i;

        for (i = 0; i < LCUI_WORKER_NUM; ++i) {
                worker_destroy(lcui_app.workers[i]);
                lcui_app.workers[i] = NULL;
        }
        worker_destroy(lcui_app.main_worker);
        lcui_app.main_worker = NULL;
}

void lcui_init(void)
{
        lcui_init_app();
        if (ptk_init(L"LCUI Application") != 0) {
                abort();
        }
        ptk_set_event_dispatcher(lcui_dispatch_app_event);
        lcui_init_ui();
}

void lcui_destroy(void)
{
        lcui_destroy_ui();
        lcui_destroy_app();
        ptk_destroy();
}

void lcui_exit(int code)
{
        app_exit(code);
}

void lcui_quit(void)
{
        lcui_exit(0);
}

int lcui_run(void)
{
        return lcui_process_events(PTK_PROCESS_EVENTS_UNTIL_QUIT);
}

int lcui_main(void)
{
        int exit_code = lcui_run();
        lcui_destroy();
        return exit_code;
}
