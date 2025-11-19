# Backend Integration Changes
# 后端集成修改记录

## Overview
## 概述

This document records modifications made to integrate the frontend AI analysis feature with the backend API implementation.

本文档记录了将前端 AI 分析功能与后端 API 实现集成所做的修改。

## Date
## 日期

2025-11-19

## Modified Files
## 修改的文件

### 1. `app/coffee/modules/issues/ai-analysis.service.coffee`

**Location**: Lines 22-40 and Lines 48-68

**位置**：第 22-40 行和第 48-68 行

**Changes**:
**修改内容**：

#### Change 1: Replaced mock data with real API call
#### 修改 1：将模拟数据替换为真实 API 调用

**Before**:
**修改前**：
```coffeescript
analyzeIssues: (projectId, issues) ->
    deferred = @q.defer()

    # Mock implementation with setTimeout
    @timeout =>
        results = @._generateMockAnalysis(issues)
        deferred.resolve(results)
    , 1500

    return deferred.promise
```

**After**:
**修改后**：
```coffeescript
analyzeIssues: (projectId, issues) ->
    deferred = @q.defer()

    @http.post(@.apiUrl, {
        project_id: projectId,
        issue_ids: _.map(issues, (issue) -> issue.id),
        issues: @._formatIssuesForApi(issues)
    }).then (response) =>
        results = @._transformBackendResponse(response.data.results)
        deferred.resolve(results)
    .catch (error) =>
        deferred.reject(error)

    return deferred.promise
```

**Reason**: Enable actual communication with backend API instead of using mock data.

**原因**：启用与后端 API 的实际通信，替代使用模拟数据。

#### Change 2: Added response transformation method
#### 修改 2：添加响应转换方法

**Added new method** `_transformBackendResponse`:
**新增方法** `_transformBackendResponse`：

```coffeescript
_transformBackendResponse: (backendResults) ->
    return _.map backendResults, (result) ->
        return {
            issueId: result.issue_id,
            issueRef: "##{result.issue_ref}",
            subject: result.subject,
            analysis: {
                priority: result.analysis.priority,
                priorityReason: result.analysis.priority_reason,
                type: result.analysis.type,
                severity: result.analysis.severity,
                description: result.analysis.description,
                relatedModules: result.analysis.related_modules,
                solutions: result.analysis.solutions,
                confidence: result.analysis.confidence
            }
        }
```

**Reason**: Transform backend response from snake_case to camelCase to match frontend data structure expectations. Also adds "#" prefix to issue reference numbers.

**原因**：将后端响应从 snake_case 转换为 camelCase 以匹配前端数据结构期望。同时为 issue 引用编号添加 "#" 前缀。

## Field Mapping
## 字段映射

| Backend Field | Frontend Field | Transformation |
|--------------|----------------|----------------|
| `issue_id` | `issueId` | Direct mapping |
| `issue_ref` | `issueRef` | Add "#" prefix |
| `priority_reason` | `priorityReason` | Direct mapping |
| `related_modules` | `relatedModules` | Direct mapping |
| Other fields | Same | Direct mapping |

## Preserved Code
## 保留的代码

The following mock data generation methods were kept for potential future testing needs:

为了潜在的未来测试需求，保留了以下模拟数据生成方法：

- `_generateMockAnalysis()`
- `_generateMockDescription()`
- `_getPriorityReason()`
- `_shuffleArray()`

These methods are no longer called in the main execution path but remain available for unit testing or fallback scenarios.

这些方法不再在主执行路径中调用，但仍可用于单元测试或备用场景。

## Configuration Requirements
## 配置要求

The backend API endpoint must be properly configured in the application config:

后端 API 端点必须在应用配置中正确配置：

- Base API URL: Retrieved via `@config.get('api')`
  - 基础 API URL：通过 `@config.get('api')` 获取
- Full endpoint: `{baseUrl}/issues/ai-analyze`
  - 完整端点：`{baseUrl}/issues/ai-analyze`

## Testing Considerations
## 测试注意事项

1. Ensure backend server is running before testing
   - 测试前确保后端服务器正在运行
2. Verify authentication tokens are properly transmitted
   - 验证认证令牌是否正确传输
3. Check network requests in browser developer tools
   - 在浏览器开发者工具中检查网络请求
4. Validate response data structure matches expectations
   - 验证响应数据结构是否符合预期

## Backwards Compatibility
## 向后兼容性

The changes maintain the same public interface (`analyzeIssues` method signature), ensuring no breaking changes for components that depend on this service.

这些更改保持了相同的公共接口（`analyzeIssues` 方法签名），确保依赖此服务的组件不会出现破坏性更改。

## Error Handling
## 错误处理

Error handling is delegated to the calling component via promise rejection. The service properly propagates HTTP errors from the backend.

错误处理通过 promise 拒绝委托给调用组件。该服务正确传播来自后端的 HTTP 错误。

## Next Steps
## 下一步

1. Deploy backend with `.env` configuration
   - 部署后端并配置 `.env` 文件
2. Test integration in development environment
   - 在开发环境中测试集成
3. Monitor API response times and adjust timeout if needed
   - 监控 API 响应时间，必要时调整超时设置
4. Consider adding response caching for frequently analyzed issues
   - 考虑为频繁分析的 issues 添加响应缓存
