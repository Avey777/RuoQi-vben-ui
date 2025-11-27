import type { BaseResp } from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  InitializeDatabase = '/sys_admin/core/init/database',
  InitializeJobDatabase = '/sys_admin/core/init/job_database',
  InitializeMcmsDatabase = '/sys_admin/core/init/mcms_database',
}

/**
 * @description: initialize the core database
 */

export const initialzeCoreDatabase = () => {
  return requestClient.get<BaseResp>(Api.InitializeDatabase);
};

/**
 * @description: initialize the job management service database
 */

export const initializeJobDatabase = () => {
  return requestClient.get<BaseResp>(Api.InitializeJobDatabase);
};

/**
 * @description: initialize the message center management service database
 */

export const initializeMcmsDatabase = () => {
  return requestClient.get<BaseResp>(Api.InitializeMcmsDatabase);
};
