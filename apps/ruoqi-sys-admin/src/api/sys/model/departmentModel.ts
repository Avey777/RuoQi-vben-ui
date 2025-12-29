import type { BaseListResp } from '../../model/baseModel';

/**
 *  @description: Department info response
 */
export interface DepartmentInfo {
  id?: string;
  createdAt?: number;
  updatedAt?: number;
  trans?: string;
  status?: number;
  sort?: number;
  name?: string;
  ancestors?: string;
  leader?: string;
  phone?: string;
  email?: string;
  remark?: string;
  parentId?: string;
}

/**
 *  @description: Department list response
 */

export type DepartmentListResp = BaseListResp<DepartmentInfo>;
