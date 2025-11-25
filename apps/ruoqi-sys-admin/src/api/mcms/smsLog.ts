import {
  type BaseDataResp,
  type BaseListReq,
  type BaseResp,
  type BaseUUIDReq,
  type BaseUUIDsReq,
} from '#/api/model/baseModel';
import { requestClient } from '#/api/request';

import { type SmsLogInfo, type SmsLogListResp } from './model/smsLogModel';

enum Api {
  CreateSmsLog = '/sys-admin/sms_log/create',
  DeleteSmsLog = '/sys-admin/sms_log/delete',
  GetSmsLogById = '/sys-admin/sms_log',
  GetSmsLogList = '/sys-admin/sms_log/list',
  UpdateSmsLog = '/sys-admin/sms_log/update',
}

/**
 * @description: Get sms log list
 */

export const getSmsLogList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<SmsLogListResp>>(
    Api.GetSmsLogList,
    params,
  );
};

/**
 *  @description: Create a new sms log
 */
export const createSmsLog = (params: SmsLogInfo) => {
  return requestClient.post<BaseResp>(Api.CreateSmsLog, params);
};

/**
 *  @description: Update the sms log
 */
export const updateSmsLog = (params: SmsLogInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateSmsLog, params);
};

/**
 *  @description: Delete sms logs
 */
export const deleteSmsLog = (params: BaseUUIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteSmsLog, params);
};

/**
 *  @description: Get sms log By ID
 */
export const getSmsLogById = (params: BaseUUIDReq) => {
  return requestClient.post<BaseDataResp<SmsLogInfo>>(
    Api.GetSmsLogById,
    params,
  );
};
