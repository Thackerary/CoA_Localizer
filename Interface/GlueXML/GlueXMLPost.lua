-- ==========================================================================
--  CoA AI Localizer · 登录/选角/建角界面 (GlueXML) 专用汉化脚本
--  路径：Interface\GlueXML\GlueXMLPost.lua
-- ==========================================================================

-- 只在登录/选角 (Glue) 环境下运行，且防止客户端与 DLL 双重注入重复执行
if GlueParent == nil or _G.CoA_GlueXMLPost_Active then
    return
end
_G.CoA_GlueXMLPost_Active = true

local glueFrame = CreateFrame("Frame", "CoA_GlueTranslatorFrame", GlueParent)

-- 选角界面玩家角色名保护开关（true = 玩家自己的角色名字一律原样保留，不走词典与 AI 翻译）
local PROTECT_GLUE_CHAR_NAMES = true

local function SafeGetTime()
    if GetTime then return GetTime() end
    if os and os.clock then return os.clock() end
    return 0
end

local function EscapeLuaPattern(s)
    return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- ==================== 1. 登录/选角界面内置高频词条与 21 职业/种族词表 ====================
local GLUE_BUILTIN_TERMS = {
    -- CoA 21 职业与原版职业
    ["Barbarian"]        = "野蛮人",
    ["Guardian"]         = "守护者",
    ["Necromancer"]      = "死灵法师",
    ["Pyromancer"]       = "烈焰术士",
    ["Venomancer"]       = "剧毒术士",
    ["Monk"]             = "武僧",
    ["Demon Hunter"]     = "恶魔猎手",
    ["Stormbringer"]     = "风暴使者",
    ["Son of Arugal"]    = "阿鲁高之子",
    ["Witch Hunter"]     = "女巫猎人",
    ["Runemaster"]       = "符文大师",
    ["Cultist"]          = "邪教徒",
    ["Ranger"]           = "游侠",
    ["Tinker"]           = "工匠",
    ["Knight of Xoroth"] = "克索罗斯骑士",
    ["Sun Cleric"]       = "太阳祭司",
    ["Witch Doctor"]     = "巫医",
    ["Primalist"]        = "原始主义者",
    ["Starcaller"]       = "唤星者",
    ["Chronomancer"]     = "时空法师",
    ["Reaper"]           = "夺魂者",
    ["Templar"]          = "圣殿骑士",
    ["Warrior"]          = "战士",
    ["Paladin"]          = "圣骑士",
    ["Hunter"]           = "猎人",
    ["Rogue"]            = "潜行者",
    ["Priest"]           = "牧师",
    ["Death Knight"]     = "死亡骑士",
    ["Shaman"]           = "萨满祭司",
    ["Mage"]             = "法师",
    ["Warlock"]          = "术士",
    ["Druid"]            = "德鲁伊",
    ["Hero"]             = "英雄",
    -- 种族
    ["Human"]            = "人类",
    ["Dwarf"]            = "矮人",
    ["Night Elf"]        = "暗夜精灵",
    ["Gnome"]            = "侏儒",
    ["Draenei"]          = "德莱尼",
    ["Worgen"]           = "狼人",
    ["High Elf"]         = "高等精灵",
    ["Orc"]              = "兽人",
    ["Undead"]           = "亡灵",
    ["Scourge"]          = "亡灵",
    ["Tauren"]           = "牛头人",
    ["Troll"]            = "巨魔",
    ["Blood Elf"]        = "血精灵",
    ["Goblin"]           = "地精",
    ["Pandaren"]         = "熊猫人",
    ["Nightborne"]       = "夜之子",
    ["Void Elf"]         = "虚空精灵",
    ["Vulpera"]          = "狐人",
    ["Lightforged"]      = "光铸德莱尼",
    ["Zandalari"]        = "赞达拉巨魔",
    ["Dark Iron"]        = "黑铁矮人",
    ["Forest Troll"]     = "森林巨魔",
    -- 登录、选角、建角、服务器列表高频 UI 文本
    ["Login"]                       = "登录",
    ["Account Name"]                = "账号名称",
    ["Account Password"]            = "账号密码",
    ["Remember Account Name"]       = "记住账号名称",
    ["Quit"]                        = "退出",
    ["Credits"]                     = "制作人员",
    ["Cinematics"]                  = "片头动画",
    ["Options"]                     = "选项",
    ["System"]                      = "系统",
    ["Community"]                   = "社区",
    ["Enter World"]                 = "进入世界",
    ["Create New Character"]        = "创建新角色",
    ["Delete Character"]            = "删除角色",
    ["Change Realm"]                = "更换服务器",
    ["AddOns"]                      = "插件",
    ["Back"]                        = "返回",
    ["Accept"]                      = "接受",
    ["Cancel"]                      = "取消",
    ["Okay"]                        = "确定",
    ["Yes"]                         = "是",
    ["No"]                          = "否",
    ["Randomize"]                   = "随机外观",
    ["Customize"]                   = "自定义",
    ["Name"]                        = "名字",
    ["Gender"]                      = "性别",
    ["Male"]                        = "男性",
    ["Female"]                      = "女性",
    ["Skin Color"]                  = "肤色",
    ["Face"]                        = "脸型",
    ["Hair Style"]                  = "发型",
    ["Hair Color"]                  = "发色",
    ["Facial Hair"]                 = "面部特征",
    ["Features"]                    = "特征",
    ["Alliance"]                    = "联盟",
    ["Horde"]                       = "部落",
    ["Realm Name"]                  = "服务器名称",
    ["Type"]                        = "类型",
    ["Characters"]                  = "角色",
    ["Population"]                  = "负载",
    ["Low"]                         = "低",
    ["Medium"]                      = "中",
    ["High"]                        = "高",
    ["Full"]                        = "满",
    ["Offline"]                     = "离线",
    ["Recommended"]                 = "推荐",
    ["Connecting..."]               = "正在连接...",
    ["Authenticating..."]           = "正在验证...",
    ["Handshaking..."]              = "正在握手...",
    ["Retrieving character list..."]= "正在获取角色列表...",
    ["Retrieving realm list..."]    = "正在获取服务器列表...",
    ["Logging in to game server..."]= "正在登录游戏服务器...",
    ["Success!"]                    = "成功！",
    ["Connected"]                   = "已连接",
    ["Ghost"]                       = "灵魂状态",
}

local INLINE_RACE_CLASS_LIST = {
    { pat = "%f[%a]Knight of Xoroth%f[^%a]", zh = "克索罗斯骑士" },
    { pat = "%f[%a]Son of Arugal%f[^%a]",    zh = "阿鲁高之子" },
    { pat = "%f[%a]Demon Hunter%f[^%a]",     zh = "恶魔猎手" },
    { pat = "%f[%a]Witch Hunter%f[^%a]",     zh = "女巫猎人" },
    { pat = "%f[%a]Witch Doctor%f[^%a]",     zh = "巫医" },
    { pat = "%f[%a]Death Knight%f[^%a]",     zh = "死亡骑士" },
    { pat = "%f[%a]Stormbringer%f[^%a]",     zh = "风暴使者" },
    { pat = "%f[%a]Chronomancer%f[^%a]",     zh = "时空法师" },
    { pat = "%f[%a]Necromancer%f[^%a]",      zh = "死灵法师" },
    { pat = "%f[%a]Pyromancer%f[^%a]",       zh = "烈焰术士" },
    { pat = "%f[%a]Venomancer%f[^%a]",       zh = "剧毒术士" },
    { pat = "%f[%a]Runemaster%f[^%a]",       zh = "符文大师" },
    { pat = "%f[%a]Starcaller%f[^%a]",       zh = "唤星者" },
    { pat = "%f[%a]Sun Cleric%f[^%a]",       zh = "太阳祭司" },
    { pat = "%f[%a]Barbarian%f[^%a]",        zh = "野蛮人" },
    { pat = "%f[%a]Primalist%f[^%a]",        zh = "原始主义者" },
    { pat = "%f[%a]Guardian%f[^%a]",         zh = "守护者" },
    { pat = "%f[%a]Cultist%f[^%a]",          zh = "邪教徒" },
    { pat = "%f[%a]Ranger%f[^%a]",           zh = "游侠" },
    { pat = "%f[%a]Tinker%f[^%a]",           zh = "工匠" },
    { pat = "%f[%a]Reaper%f[^%a]",           zh = "夺魂者" },
    { pat = "%f[%a]Templar%f[^%a]",          zh = "圣殿骑士" },
    { pat = "%f[%a]Monk%f[^%a]",             zh = "武僧" },
    { pat = "%f[%a]Warrior%f[^%a]",          zh = "战士" },
    { pat = "%f[%a]Paladin%f[^%a]",          zh = "圣骑士" },
    { pat = "%f[%a]Hunter%f[^%a]",           zh = "猎人" },
    { pat = "%f[%a]Rogue%f[^%a]",            zh = "潜行者" },
    { pat = "%f[%a]Priest%f[^%a]",           zh = "牧师" },
    { pat = "%f[%a]Shaman%f[^%a]",           zh = "萨满祭司" },
    { pat = "%f[%a]Mage%f[^%a]",             zh = "法师" },
    { pat = "%f[%a]Warlock%f[^%a]",          zh = "术士" },
    { pat = "%f[%a]Druid%f[^%a]",            zh = "德鲁伊" },
    { pat = "%f[%a]Hero%f[^%a]",             zh = "英雄" },
    { pat = "%f[%a]Forest Troll%f[^%a]",     zh = "森林巨魔" },
    { pat = "%f[%a]Lightforged%f[^%a]",      zh = "光铸德莱尼" },
    { pat = "%f[%a]Nightborne%f[^%a]",       zh = "夜之子" },
    { pat = "%f[%a]Night Elf%f[^%a]",        zh = "暗夜精灵" },
    { pat = "%f[%a]Blood Elf%f[^%a]",        zh = "血精灵" },
    { pat = "%f[%a]High Elf%f[^%a]",         zh = "高等精灵" },
    { pat = "%f[%a]Void Elf%f[^%a]",         zh = "虚空精灵" },
    { pat = "%f[%a]Dark Iron%f[^%a]",        zh = "黑铁矮人" },
    { pat = "%f[%a]Zandalari%f[^%a]",        zh = "赞达拉巨魔" },
    { pat = "%f[%a]Pandaren%f[^%a]",         zh = "熊猫人" },
    { pat = "%f[%a]Draenei%f[^%a]",          zh = "德莱尼" },
    { pat = "%f[%a]Worgen%f[^%a]",           zh = "狼人" },
    { pat = "%f[%a]Undead%f[^%a]",           zh = "亡灵" },
    { pat = "%f[%a]Scourge%f[^%a]",          zh = "亡灵" },
    { pat = "%f[%a]Tauren%f[^%a]",           zh = "牛头人" },
    { pat = "%f[%a]Goblin%f[^%a]",           zh = "地精" },
    { pat = "%f[%a]Vulpera%f[^%a]",          zh = "狐人" },
    { pat = "%f[%a]Human%f[^%a]",            zh = "人类" },
    { pat = "%f[%a]Dwarf%f[^%a]",            zh = "矮人" },
    { pat = "%f[%a]Gnome%f[^%a]",            zh = "侏儒" },
    { pat = "%f[%a]Troll%f[^%a]",            zh = "巨魔" },
    { pat = "%f[%a]Orc%f[^%a]",              zh = "兽人" },
}

-- ==================== 2. 选角列表玩家角色名保护 ====================
local PROTECTED = {}
local pendingFS   = setmetatable({}, { __mode = "k" })
local pendingBtns = setmetatable({}, { __mode = "k" })

local function ProtectName(name)
    if type(name) ~= "string" or name == "" or name == "Unknown" then return end
    if #name > 24 then return end
    if not PROTECTED[name] then
        PROTECTED[name] = true
        for k, info in pairs(pendingFS) do
            if info.rawText == name or info.tmpl == name then pendingFS[k] = nil end
        end
        for k, info in pairs(pendingBtns) do
            if info.rawText == name or info.tmpl == name then pendingBtns[k] = nil end
        end
    end
end

local lastGlueCharCount = -1
local function HarvestGlueCharacterNames()
    if not PROTECT_GLUE_CHAR_NAMES then return end
    if not GetNumCharacters or not GetCharacterInfo then return end
    local ok, num = pcall(GetNumCharacters)
    if not ok or type(num) ~= "number" or num <= 0 then return end
    if num == lastGlueCharCount then return end
    lastGlueCharCount = num
    for i = 1, num do
        local okInfo, charName = pcall(GetCharacterInfo, i)
        if okInfo and type(charName) == "string" and charName ~= "" then
            ProtectName(charName)
        end
    end
end

local function IsGlueCharacterNameWidget(obj)
    if not PROTECT_GLUE_CHAR_NAMES or not obj or not obj.GetName then return false end
    local name = obj:GetName()
    if type(name) ~= "string" then return false end
    if name == "CharSelectCharacterName" then return true end
    if string.find(name, "^CharSelectCharacterButton%d+ButtonTextName$") then return true end
    return false
end

-- ==================== 3. IPC 通信控件与底层元表获取 ====================
local ipcFS = glueFrame:CreateFontString(nil, "OVERLAY", "GlueFontNormal")
if not ipcFS:GetFont() then
    ipcFS:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12)
end
ipcFS:Hide()

local sampleFS = glueFrame:CreateFontString(nil, "OVERLAY", "GlueFontNormal")
if not sampleFS:GetFont() then
    sampleFS:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12)
end
sampleFS:Hide()

local fsMeta                   = getmetatable(sampleFS).__index
local orig_FS_SetText          = fsMeta.SetText
local orig_FS_GetText          = fsMeta.GetText
local orig_FS_SetFormattedText = fsMeta.SetFormattedText

local sampleBtn = CreateFrame("Button", nil, GlueParent)
sampleBtn:Hide()
local btnMeta                   = getmetatable(sampleBtn).__index
local orig_Btn_SetText          = btnMeta.SetText
local orig_Btn_GetText          = btnMeta.GetText
local orig_Btn_SetFormattedText = btnMeta.SetFormattedText

local sampleHTML = CreateFrame("SimpleHTML", nil, GlueParent)
sampleHTML:Hide()
local htmlMeta          = getmetatable(sampleHTML).__index
local orig_HTML_SetText = htmlMeta and htmlMeta.SetText

local fsRawText   = setmetatable({}, { __mode = "k" })
local fsZhText    = setmetatable({}, { __mode = "k" })
local btnRawText  = setmetatable({}, { __mode = "k" })
local btnZhText   = setmetatable({}, { __mode = "k" })
local htmlRawText = setmetatable({}, { __mode = "k" })
local pendingHTML = setmetatable({}, { __mode = "k" })

-- ==================== 4. L0 缓存体系与 DLL 通信（@COA_LK@ / @COA_TR@ / @COA_POLL@） ====================
local L0_TemplateCache = {}
local L0_MissCache     = {}
local L0_ExactCache    = {}
local L0_RawCache      = {}

for en, zh in pairs(GLUE_BUILTIN_TERMS) do
    L0_TemplateCache[en] = zh
end
if CoA_PredefinedTerms then
    for en, zh in pairs(CoA_PredefinedTerms) do
        L0_TemplateCache[en] = zh
    end
end
if CoA_GlueDict then
    for en, zh in pairs(CoA_GlueDict) do
        L0_TemplateCache[en] = zh
    end
end

local backendState = "unknown"
local backendEchoCount = 0
local backendRetryAt = 0
local MAX_RETRIES = 80

-- 只读查询 DLL 内存中的 dict_local.bin + dict.json（不触发 AI 队列）
local function LookupDict(tmpl)
    if type(tmpl) ~= "string" or tmpl == "" then return nil end
    local zh = L0_TemplateCache[tmpl]
    if zh then return zh end
    if L0_MissCache[tmpl] then return nil end

    if backendState ~= "off" or SafeGetTime() >= backendRetryAt then
        local sent = "@COA_LK@" .. tmpl
        orig_FS_SetText(ipcFS, sent)
        local res = orig_FS_GetText(ipcFS)
        if res == sent then
            backendEchoCount = backendEchoCount + 1
            if backendEchoCount >= 3 then
                backendState = "off"
                backendRetryAt = SafeGetTime() + 30
            end
            return nil
        end
        backendEchoCount = 0
        backendState = "ok"
        if type(res) == "string" and res ~= "" and res ~= tmpl then
            L0_TemplateCache[tmpl] = res
            return res
        end
        L0_MissCache[tmpl] = true
    end
    return nil
end

-- 查询 DLL 词典，若未命中则自动推入 DLL 后台 AI 翻译队列并固化至本地 dict.json
local function RawIPCTranslate(templateStr)
    if L0_TemplateCache[templateStr] then
        return L0_TemplateCache[templateStr], true
    end
    if backendState == "off" and SafeGetTime() < backendRetryAt then
        return templateStr, false
    end
    local sent = "@COA_TR@" .. templateStr
    orig_FS_SetText(ipcFS, sent)
    local res = orig_FS_GetText(ipcFS) or sent

    if res == sent then
        backendEchoCount = backendEchoCount + 1
        if backendEchoCount >= 3 then
            backendState = "off"
            backendRetryAt = SafeGetTime() + 30
        end
        return templateStr, false
    end

    backendEchoCount = 0
    backendState = "ok"
    if res ~= templateStr and res ~= "" then
        res = res:gsub("^@COA_TR@", "")
        L0_TemplateCache[templateStr] = res
        L0_MissCache[templateStr] = nil
        return res, true
    end
    return templateStr, false
end

local function PollBackendDirty()
    orig_FS_SetText(ipcFS, "@COA_POLL@")
    return orig_FS_GetText(ipcFS) == "1"
end

-- ==================== 5. 选角界面种族/职业/等级内联解析与模板归一化 ====================
local function TryReplaceInlineRaceClass(str)
    local work = str
    local changed = false
    -- 处理选角按钮常见的 "Level 40 Guardian" / "等级 40 Guardian" 格式
    if string.find(work, "^%s*[Ll]evel%s+%d+") then
        work = work:gsub("^%s*[Ll]evel%s+(%d+)", "等级 %1")
        changed = true
    end
    if string.find(work, "%([Gg]host%)") then
        work = work:gsub("%([Gg]host%)", "（灵魂）")
        changed = true
    end
    for i = 1, #INLINE_RACE_CLASS_LIST do
        local item = INLINE_RACE_CLASS_LIST[i]
        if string.find(work, item.pat) then
            work = work:gsub(item.pat, item.zh)
            changed = true
        end
    end
    if not changed then return nil end
    local check = work
        :gsub("|T.-|t", "")
        :gsub("|H.-|h", "")
        :gsub("|c%x%x%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("|n", "")
        :gsub("{[A-Z0-9]+}", "")
    if not string.find(check, "[a-zA-Z][a-zA-Z]") then
        return work
    end
    return nil
end

local function ExtractNumbersSinglePass(str, vars)
    local nIdx = 0
    local out = str:gsub("(%d[%d,%.]*)", function(m)
        local core, trail = string.match(m, "^(.-)([%.,]+)$")
        if not core or core == "" then
            core = m
            trail = ""
        end
        nIdx = nIdx + 1
        local key = "{" .. nIdx .. "}"
        vars[key] = core
        return key .. trail
    end)
    return out
end

local function ShouldTranslateTemplate(tmpl)
    if type(tmpl) ~= "string" or #tmpl < 2 then return false end
    if string.find(tmpl, "[\228-\233][\128-\191][\128-\191]") then return false end
    local stripped = tmpl:gsub("{[A-Z0-9]+}", ""):gsub("|r", "")
    if not string.find(stripped, "[a-zA-Z][a-zA-Z]") then return false end
    if string.match(stripped, "^%s*[fF][pP][sS]%s*$") or
       string.match(stripped, "^%s*[mM][sS]%s*$") then
        return false
    end
    return true
end

local function NormalizeText(raw)
    if type(raw) ~= "string" or #raw < 2 then return raw, nil, false end
    if string.sub(raw, 1, 5) == "@COA_" then return raw, nil, false end
    if not string.find(raw, "[a-zA-Z][a-zA-Z]") then return raw, nil, false end
    -- 跳过版本号（如 "Version 3.3.5 (12340)" 保持清晰或走词典）
    if string.match(raw, "^%s*[%d%.%,]+%s*%a%a%a?%s*$") then
        return raw, nil, false
    end

    local vars = {}
    local work = raw
    local tIdx, lIdx, cIdx = 0, 0, 0
    local sentinels = {}

    if string.find(work, "|", 1, true) then
        work = work:gsub("(|T.-|t)", function(m)
            tIdx = tIdx + 1
            local key = "{T" .. tIdx .. "}"
            local sKey = "\1T" .. string.char(64 + math.min(tIdx, 26)) .. "\2"
            vars[key] = m
            sentinels[sKey] = key
            return sKey
        end)
        work = work:gsub("(|H.-|h)", function(m)
            lIdx = lIdx + 1
            local key = "{L" .. lIdx .. "}"
            local sKey = "\1L" .. string.char(64 + math.min(lIdx, 26)) .. "\2"
            vars[key] = m
            sentinels[sKey] = key
            return sKey
        end)
        work = work:gsub("(|c%x%x%x%x%x%x%x%x)", function(m)
            cIdx = cIdx + 1
            local key = "{C" .. cIdx .. "}"
            local sKey = "\1C" .. string.char(64 + math.min(cIdx, 26)) .. "\2"
            vars[key] = m
            sentinels[sKey] = key
            return sKey
        end)
    end

    local zIdx = 0
    work = work:gsub("(([\228-\233][\128-\191][\128-\191])+)", function(m)
        zIdx = zIdx + 1
        local key = "{Z" .. zIdx .. "}"
        vars[key] = m
        return "\1Z" .. string.char(64 + math.min(zIdx, 26)) .. "\2"
    end)
    for i = 1, zIdx do
        sentinels["\1Z" .. string.char(64 + math.min(i, 26)) .. "\2"] = "{Z" .. i .. "}"
    end

    work = ExtractNumbersSinglePass(work, vars)
    work = work:gsub("(\1[^\2]+\2)", sentinels)

    if not ShouldTranslateTemplate(work) then
        return raw, nil, false
    end
    return work, vars, true
end

local function RestoreText(zhTemplate, vars)
    if not vars then return zhTemplate end
    return (zhTemplate:gsub("({[A-Z0-9]+})", vars))
end

local ZH_TERM_FIX = {
    ["符文巨匠"] = "符文大师",
    ["观星者"]   = "唤星者",
    ["太阳牧师"] = "太阳祭司",
    ["無境銀行"] = "禁止使用银行",
}

local function FixZhTerms(raw)
    if type(raw) ~= "string" or not string.find(raw, "[\228-\233][\128-\191][\128-\191]") then
        return raw
    end
    local out = raw
    for bad, good in pairs(ZH_TERM_FIX) do
        if string.find(out, bad, 1, true) then
            out = out:gsub(bad, good)
        end
    end
    return out
end

local ProcessTranslation

local function TryParagraphStaticLookup(rawText)
    if not string.find(rawText, "\n", 1, true) then return nil end
    local anyHit = false
    local allHit = true
    local out = rawText:gsub("([^\r\n]+)", function(para)
        if not string.find(para, "[a-zA-Z][a-zA-Z]") then return para end
        local pZh = LookupDict(para)
        if pZh then
            anyHit = true
            return pZh
        end
        local pTmpl, pVars, pNeed = NormalizeText(para)
        if not pNeed then return para end
        local tZh = LookupDict(pTmpl)
        if tZh then
            anyHit = true
            return RestoreText(tZh, pVars)
        end
        allHit = false
        return para
    end)
    if anyHit and allHit then return out end
    return nil
end

ProcessTranslation = function(rawText)
    if type(rawText) ~= "string" or rawText == "" then
        return rawText, true, nil, nil
    end
    HarvestGlueCharacterNames()
    if PROTECTED[rawText] then
        return rawText, true, nil, nil
    end

    local exact = L0_ExactCache[rawText]
    if exact then return exact, true, rawText, nil end

    local cached = L0_RawCache[rawText]
    if cached then return cached, true, nil, nil end

    if L0_TemplateCache[rawText] then
        return L0_TemplateCache[rawText], true, rawText, nil
    end

    local inlineRC = TryReplaceInlineRaceClass(rawText)
    if inlineRC then
        L0_ExactCache[rawText] = inlineRC
        L0_RawCache[rawText]   = inlineRC
        return inlineRC, true, nil, nil
    end

    local directZh = LookupDict(rawText)
    if directZh then
        L0_ExactCache[rawText] = directZh
        return directZh, true, rawText, nil
    end

    local hasCJK = string.find(rawText, "[\228-\233][\128-\191][\128-\191]")
    if hasCJK then
        local cleanCheck = rawText:gsub("|T.-|t", ""):gsub("|H.-|h", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|n", "")
        if not string.find(cleanCheck, "[a-zA-Z][a-zA-Z]") then
            local fixed = FixZhTerms(rawText)
            L0_ExactCache[rawText] = fixed
            return fixed, true, nil, nil
        end
    end

    local tmpl, vars, needTrans = NormalizeText(rawText)
    if not needTrans then
        L0_ExactCache[rawText] = rawText
        return rawText, true, nil, nil
    end
    if PROTECTED[tmpl] then return rawText, true, nil, nil end

    local zh = LookupDict(tmpl)
    if zh then
        local final = FixZhTerms(RestoreText(zh, vars))
        L0_RawCache[rawText]   = final
        L0_ExactCache[rawText] = final
        return final, true, tmpl, vars
    end

    if string.find(rawText, "\n", 1, true) then
        local paraTranslated = TryParagraphStaticLookup(rawText)
        if paraTranslated then
            L0_RawCache[rawText]   = paraTranslated
            L0_ExactCache[rawText] = paraTranslated
            return paraTranslated, true, tmpl, vars
        end
    end

    local zhAI, hit = RawIPCTranslate(tmpl)
    if hit then
        local final = FixZhTerms(RestoreText(zhAI, vars))
        L0_RawCache[rawText]   = final
        L0_ExactCache[rawText] = final
        return final, true, tmpl, vars
    end

    return rawText, false, tmpl, vars
end

-- ==================== 6. UI 控件钩子（FontString / Button / SimpleHTML / GlueTooltip） ====================
local isApplyingFS   = false
local isApplyingBtn  = false
local isApplyingHTML = false

local function ApplyFontStringTranslation(fs, text)
    if type(text) ~= "string" or text == "" then return end
    if text == fsZhText[fs] then return end
    if IsGlueCharacterNameWidget(fs) then return end
    if not fs:GetFont() then
        fs:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12)
        if not fs:GetFont() then return end
    end
    local finalStr, hit, tmpl, vars = ProcessTranslation(text)
    finalStr = FixZhTerms(finalStr)
    if finalStr and finalStr ~= "" and finalStr ~= text then
        fsRawText[fs] = text
        fsZhText[fs]  = finalStr
        isApplyingFS = true
        orig_FS_SetText(fs, finalStr)
        isApplyingFS = false
    elseif text ~= fsZhText[fs] then
        fsRawText[fs] = nil
        fsZhText[fs]  = nil
    end
    if not hit and tmpl then
        pendingFS[fs] = { rawText = text, tmpl = tmpl, vars = vars, retries = 0 }
    else
        pendingFS[fs] = nil
    end
end

local function ApplyButtonTranslation(btn, text)
    if type(text) ~= "string" or text == "" then return end
    if text == btnZhText[btn] then return end
    if IsGlueCharacterNameWidget(btn) then return end

    local finalStr, hit, tmpl, vars = ProcessTranslation(text)
    finalStr = FixZhTerms(finalStr)
    if finalStr and finalStr ~= "" and finalStr ~= text then
        btnRawText[btn] = text
        btnZhText[btn]  = finalStr
        local btnFS = btn.GetFontString and btn:GetFontString()
        if btnFS then
            fsRawText[btnFS] = text
            fsZhText[btnFS]  = finalStr
        end
        isApplyingBtn = true
        isApplyingFS  = true
        orig_Btn_SetText(btn, finalStr)
        isApplyingFS  = false
        isApplyingBtn = false
    elseif text ~= btnZhText[btn] then
        btnRawText[btn] = nil
        btnZhText[btn]  = nil
    end
    if not hit and tmpl then
        pendingBtns[btn] = { rawText = text, tmpl = tmpl, vars = vars, retries = 0 }
    else
        pendingBtns[btn] = nil
    end
end

local function SafePostHookFS(self)
    if isApplyingFS or self == ipcFS or self == sampleFS then return end
    HarvestGlueCharacterNames()
    if IsGlueCharacterNameWidget(self) then return end
    local text = orig_FS_GetText(self)
    if type(text) == "string" and text ~= "" and text ~= fsZhText[self] then
        ApplyFontStringTranslation(self, text)
    end
end

local function SafePostHookBtn(self)
    if isApplyingBtn or self == sampleBtn then return end
    HarvestGlueCharacterNames()
    if IsGlueCharacterNameWidget(self) then return end
    local txt = orig_Btn_GetText(self)
    if type(txt) == "string" and txt ~= "" and txt ~= btnZhText[self] then
        ApplyButtonTranslation(self, txt)
    end
    local btnFS = self.GetFontString and self:GetFontString()
    if btnFS and not IsGlueCharacterNameWidget(btnFS) then
        local fsTxt = orig_FS_GetText(btnFS)
        if type(fsTxt) == "string" and fsTxt ~= "" and fsTxt ~= fsZhText[btnFS] then
            ApplyFontStringTranslation(btnFS, fsTxt)
        end
    end
end

if hooksecurefunc then
    hooksecurefunc(fsMeta, "SetText", SafePostHookFS)
    hooksecurefunc(fsMeta, "SetFormattedText", SafePostHookFS)
    hooksecurefunc(btnMeta, "SetText", SafePostHookBtn)
    if orig_Btn_SetFormattedText then
        hooksecurefunc(btnMeta, "SetFormattedText", SafePostHookBtn)
    end
else
    fsMeta.SetText = function(self, text)
        orig_FS_SetText(self, text)
        SafePostHookFS(self)
    end
    fsMeta.SetFormattedText = function(self, fmt, ...)
        orig_FS_SetFormattedText(self, fmt, ...)
        SafePostHookFS(self)
    end
    btnMeta.SetText = function(self, text)
        orig_Btn_SetText(self, text)
        SafePostHookBtn(self)
    end
end

local function ProcessMultilineTranslation(rawText)
    if type(rawText) ~= "string" or rawText == "" then return rawText, true end
    local cached = L0_ExactCache[rawText]
    if cached then return cached, true end
    local allHit = true
    local result = rawText:gsub("([^\r\n]+)", function(paragraph)
        local finalPara, hit = ProcessTranslation(paragraph)
        if not hit then allHit = false end
        return finalPara
    end)
    if allHit then L0_ExactCache[rawText] = result end
    return result, allHit
end

local function ApplyHTMLTranslation(html, text)
    if type(text) ~= "string" or text == "" then
        htmlRawText[html] = nil
        pendingHTML[html] = nil
        return
    end
    htmlRawText[html] = text
    local finalStr, allHit = ProcessMultilineTranslation(text)
    isApplyingHTML = true
    orig_HTML_SetText(html, FixZhTerms(finalStr))
    isApplyingHTML = false
    if not allHit then
        pendingHTML[html] = { rawText = text, retries = 0 }
    else
        pendingHTML[html] = nil
    end
end

if htmlMeta and orig_HTML_SetText then
    if hooksecurefunc then
        hooksecurefunc(htmlMeta, "SetText", function(self, text)
            if isApplyingHTML or self == sampleHTML then return end
            ApplyHTMLTranslation(self, text)
        end)
    else
        htmlMeta.SetText = function(self, text)
            orig_HTML_SetText(self, text)
            if not isApplyingHTML and self ~= sampleHTML then
                ApplyHTMLTranslation(self, text)
            end
        end
    end
end

-- 劫持 GlueTooltip
local function ScanGlueTooltipRegions(tooltip)
    if not tooltip or not tooltip.GetRegions then return end
    local n = select("#", tooltip:GetRegions())
    for i = 1, n do
        local region = select(i, tooltip:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            local text = orig_FS_GetText(region)
            if type(text) == "string" and text ~= "" and text ~= fsZhText[region] then
                ApplyFontStringTranslation(region, text)
            end
        end
    end
end

if GlueTooltip then
    if GlueTooltip.HookScript then
        pcall(GlueTooltip.HookScript, GlueTooltip, "OnShow", ScanGlueTooltipRegions)
    end
    local gtMeta = getmetatable(GlueTooltip) and getmetatable(GlueTooltip).__index
    if gtMeta and hooksecurefunc then
        if gtMeta.SetText then hooksecurefunc(gtMeta, "SetText", ScanGlueTooltipRegions) end
        if gtMeta.AddLine then hooksecurefunc(gtMeta, "AddLine", ScanGlueTooltipRegions) end
    end
end

-- ==================== 7. 全量静态控件扫描与选角事件监听 ====================
local function ScanFrameRegionsVararg(...)
    local n = select("#", ...)
    for i = 1, n do
        local region = select(i, ...)
        if region and region ~= ipcFS and region ~= sampleFS
           and region:GetObjectType() == "FontString"
           and not IsGlueCharacterNameWidget(region) then
            local curTxt = orig_FS_GetText(region)
            local rawTxt = (curTxt and curTxt == fsZhText[region] and fsRawText[region]) or curTxt
            if type(rawTxt) == "string" and rawTxt ~= "" then
                fsZhText[region] = nil
                ApplyFontStringTranslation(region, rawTxt)
            end
        end
    end
end

local function SweepGlueStaticUI()
    HarvestGlueCharacterNames()
    if not EnumerateFrames then return end
    local f = EnumerateFrames()
    while f do
        if f ~= glueFrame and f ~= sampleBtn and f ~= sampleHTML then
            if f:IsObjectType("Button") and not IsGlueCharacterNameWidget(f) then
                local curTxt = orig_Btn_GetText(f)
                local rawTxt = (curTxt and curTxt == btnZhText[f] and btnRawText[f]) or curTxt
                if type(rawTxt) == "string" and rawTxt ~= "" then
                    btnZhText[f] = nil
                    ApplyButtonTranslation(f, rawTxt)
                end
            end
            if f.GetRegions then
                ScanFrameRegionsVararg(f.GetRegions(f))
            end
        end
        f = EnumerateFrames(f)
    end
end

-- 钩住选角/建角/服务器列表刷新函数，在角色列表更新瞬間优先保护玩家角色名并翻译职业/地点
if hooksecurefunc then
    if _G.CharacterSelect_Update then
        hooksecurefunc("CharacterSelect_Update", function()
            lastGlueCharCount = -1
            HarvestGlueCharacterNames()
            SweepGlueStaticUI()
        end)
    end
    if _G.CharacterCreate_OnShow then
        hooksecurefunc("CharacterCreate_OnShow", SweepGlueStaticUI)
    end
    if _G.RealmListUpdate then
        hooksecurefunc("RealmListUpdate", SweepGlueStaticUI)
    end
end

local glueEvents = {
    "CHARACTER_LIST_UPDATE",
    "UPDATE_SELECTED_CHARACTER",
    "UPDATE_STATUS_DIALOG",
    "OPEN_REALM_LIST",
    "ADDON_LIST_UPDATE",
}
for _, ev in ipairs(glueEvents) do
    pcall(glueFrame.RegisterEvent, glueFrame, ev)
end

glueFrame:SetScript("OnEvent", function(self, event)
    if event == "CHARACTER_LIST_UPDATE" or event == "UPDATE_SELECTED_CHARACTER" then
        lastGlueCharCount = -1
        HarvestGlueCharacterNames()
    end
    SweepGlueStaticUI()
end)

-- ==================== 8. 异步 AI 译文轮询与原地回填器 ====================
local pollTimer = 0
local pendingTimer = 0
glueFrame:SetScript("OnUpdate", function(self, elapsed)
    HarvestGlueCharacterNames()

    pollTimer = pollTimer + elapsed
    pendingTimer = pendingTimer + elapsed
    if pollTimer < 0.2 then return end
    pollTimer = 0

    if next(pendingFS) == nil and next(pendingBtns) == nil and next(pendingHTML) == nil then
        pendingTimer = 0
        return
    end

    local dirty = PollBackendDirty()
    if not dirty and pendingTimer < 1.0 then return end
    pendingTimer = 0

    for fs, info in pairs(pendingFS) do
        if PROTECTED[info.rawText] or PROTECTED[info.tmpl] or IsGlueCharacterNameWidget(fs) then
            pendingFS[fs] = nil
        else
            local currentText = orig_FS_GetText(fs)
            if currentText == info.rawText then
                local zhTmpl = L0_TemplateCache[info.tmpl]
                local hit = (zhTmpl ~= nil)
                if not hit and dirty then
                    zhTmpl, hit = RawIPCTranslate(info.tmpl)
                end
                if hit then
                    if not fs:GetFont() then
                        fs:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12)
                    end
                    local zhOut = FixZhTerms(RestoreText(zhTmpl, info.vars))
                    fsRawText[fs] = info.rawText
                    fsZhText[fs]  = zhOut
                    isApplyingFS = true
                    orig_FS_SetText(fs, zhOut)
                    isApplyingFS = false
                    pendingFS[fs] = nil
                else
                    info.retries = info.retries + 1
                    if info.retries >= MAX_RETRIES then
                        pendingFS[fs] = nil
                    end
                end
            else
                pendingFS[fs] = nil
            end
        end
    end

    for btn, info in pairs(pendingBtns) do
        if PROTECTED[info.rawText] or PROTECTED[info.tmpl] or IsGlueCharacterNameWidget(btn) then
            pendingBtns[btn] = nil
        else
            local currentText = orig_Btn_GetText(btn)
            if currentText == info.rawText then
                local zhTmpl = L0_TemplateCache[info.tmpl]
                local hit = (zhTmpl ~= nil)
                if not hit and dirty then
                    zhTmpl, hit = RawIPCTranslate(info.tmpl)
                end
                if hit then
                    local zhOut = FixZhTerms(RestoreText(zhTmpl, info.vars))
                    btnRawText[btn] = info.rawText
                    btnZhText[btn]  = zhOut
                    local btnFS = btn.GetFontString and btn:GetFontString()
                    if btnFS then
                        fsRawText[btnFS] = info.rawText
                        fsZhText[btnFS]  = zhOut
                    end
                    isApplyingBtn = true
                    isApplyingFS  = true
                    orig_Btn_SetText(btn, zhOut)
                    isApplyingFS  = false
                    isApplyingBtn = false
                    pendingBtns[btn] = nil
                else
                    info.retries = info.retries + 1
                    if info.retries >= MAX_RETRIES then
                        pendingBtns[btn] = nil
                    end
                end
            else
                pendingBtns[btn] = nil
            end
        end
    end

    for html, info in pairs(pendingHTML) do
        if htmlRawText[html] == info.rawText then
            if dirty then
                local finalStr, allHit = ProcessMultilineTranslation(info.rawText)
                if allHit then
                    isApplyingHTML = true
                    orig_HTML_SetText(html, FixZhTerms(finalStr))
                    isApplyingHTML = false
                    htmlRawText[html] = finalStr
                    pendingHTML[html] = nil
                else
                    info.retries = info.retries + 1
                    if info.retries >= MAX_RETRIES then pendingHTML[html] = nil end
                end
            else
                info.retries = info.retries + 1
                if info.retries >= MAX_RETRIES then pendingHTML[html] = nil end
            end
        else
            pendingHTML[html] = nil
        end
    end
end)

-- 首屏立即执行一次角色名采集与界面扫描
HarvestGlueCharacterNames()
SweepGlueStaticUI()