import type { TaskLogInfo, TaskLogListResp } from './model/taskLogModel';

import type {
  BaseDataResp,
  BaseIDReq,
  BaseIDsReq,
  BaseListReq,
  BaseResp,
} from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  CreateTaskLog = '/sys_admin/task_log/create',
  DeleteTaskLog = '/sys_admin/task_log/delete',
  GetTaskLogById = '/sys_admin/task_log',
  GetTaskLogList = '/sys_admin/task_log/list',
  UpdateTaskLog = '/sys_admin/task_log/update',
}

/**
 * @description: Get task log list
 */

export const getTaskLogList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<TaskLogListResp>>(
    Api.GetTaskLogList,
    params,
  );
};

/**
 *  @description: Create a new task log
 */
export const createTaskLog = (params: TaskLogInfo) => {
  return requestClient.post<BaseResp>(Api.CreateTaskLog, params);
};

/**
 *  @description: Update the task log
 */
export const updateTaskLog = (params: TaskLogInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateTaskLog, params);
};

/**
 *  @description: Delete task logs
 */
export const deleteTaskLog = (params: BaseIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteTaskLog, params);
};

/**
 *  @description: Get task log By ID
 */
export const getTaskLogById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<TaskLogInfo>>(
    Api.GetTaskLogById,
    params,
  );
};
