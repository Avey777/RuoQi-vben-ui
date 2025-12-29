import type { BaseListResp } from '../../model/baseModel';

/**
 *  @description: TaskLog info response
 */
export interface TaskLogInfo {
  id?: string;
  startedAt?: number;
  finishedAt?: number;
  result?: number;
}

/**
 *  @description: TaskLog list response
 */

export type TaskLogListResp = BaseListResp<TaskLogInfo>;
