const fs = require('fs');
const file = 'C:/Users/Administrator/WorkBuddy/2026-05-20-task-6/maintenance.html';
let content = fs.readFileSync(file, 'utf8');

// 1. 删除 MAINTAIN_RECORDS 数据中的 result: '...' 行（允许换行和空格）
content = content.replace(/,\s*\n\s*result:\s*'[^']*',\s*\n/g, ',\n');

// 2. 删除 loadRecordToDrawer 中处理结果相关代码
content = content.replace(/\s*\/\/ 处理结果[\s\S]*?renderDrawerHistory\(record\.history\);/g, function(match) {
  return '\n\n    // 渲染维修历史\n    renderDrawerHistory(record.history);';
});

// 3. 删除 submitRepair 中 resultRadio/result 相关代码
content = content.replace(/\s*const resultRadio =[\s\S]*?const repairer =/ g, '    const repairer =');

// 4. 删除新增记录中的 result: result,
content = content.replace(/,\s*\n\s*result:\s*result,\s*\n/g, ',\n');

// 5. 删除编辑模式中 record.result = result;
content = content.replace(/\s*record\.result = result;\s*\n/g, '\n');

// 6. 删除 setDrawerReadonly 中的 repairResult
content = content.replace(/\s*document\.querySelectorAll\('input\[name="repairResult"\]'\)\.forEach\(r => r\.disabled = readonly\);\s*\n/g, '\n');

// 7. 维修人/维修商改为非必填：删除 required 星号
content = content.replace(/<label class="form-label"><span class="required">\*<\/span>维修人\/维修商<\/label>/g, '<label class="form-label">维修人/维修商</label>');

fs.writeFileSync(file, content, 'utf8');
console.log('Done');
