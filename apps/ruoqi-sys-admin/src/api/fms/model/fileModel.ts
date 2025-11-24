import { type BaseListResp } from '../../model/baseModel';

/**
 *  author: DoDo Su
 *  @description: file info response
 */
export interface fileInfo {
  id: string;
  createdAt?: number;
  name: string;
  fileType: string;
  size: number;
  path: string;
  publicPath: string;
  tagIds: number[];
}

/**
 *  author: DoDo Su
 *  @description: file list response
 */

export type FileListResp = BaseListResp<fileInfo>;

/**
 *  author: DoDo Su
 *  @description: change status request
 */
export interface changeStatusReq {
  id: string;
  status: boolean;
}

/**
 *  author: DoDo Su
 *  @description: update file info request
 */
export interface updateFileInfoReq {
  id: string;
  name: string;
  tagIds: number[];
}
