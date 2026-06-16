-- Anomaly EFP Transaction UI
-- Handles UI display and interactions for transactions

local transaction_ui = {}
local transaction_manager = require("anomaly-efp-transaction-mod/gamedata/scripts/transaction_manager")
local pda_guide = require("anomaly-efp-transaction-mod/gamedata/scripts/pda_guide_integration")

-- UI State
transaction_ui.is_visible = false
transaction_ui.current_view = "summary" -- summary, transactions, categories

-- Initialize UI
function transaction_ui:init()
    printf("[TRANSACTION MOD] Initializing Transaction UI...")
end

-- Show transaction summary
function transaction_ui:show_summary()
    local summary = pda_guide:get_summary_display()
    
    local text = ""
    text = text .. "=== FINANCE SUMMARY ===\n\n"
    text = text .. "Total Income: [g]" .. summary.formatted_income .. "[c]\n"
    text = text .. "Total Expenses: [r]" .. summary.formatted_expenses .. "[c]\n"
    text = text .. "Net Balance: " .. summary.formatted_balance .. "\n"
    text = text .. "Total Transactions: " .. summary.transaction_count .. "\n\n"
    
    return text
end

-- Show category breakdown
function transaction_ui:show_category_breakdown()
    local categories = pda_guide:get_category_summary()
    
    local text = ""
    text = text .. "=== CATEGORY BREAKDOWN ===\n\n"
    
    if #categories == 0 then
        text = text .. "No transactions recorded yet.\n"
    else
        for _, cat_data in ipairs(categories) do
            text = text .. cat_data.formatted .. "\n"
        end
    end
    
    return text
end

-- Show transaction list
function transaction_ui:show_transaction_list(page, category_filter)
    local transactions, total = pda_guide:get_transaction_list(page, category_filter)
    local page_info = pda_guide:get_page_info(total)
    
    local text = ""
    text = text .. "=== TRANSACTION LOG ===\n"
    
    if category_filter then
        text = text .. "[Filter: " .. category_filter .. "]\n"
    end
    
    text = text .. "[Page " .. page_info.current_page .. "/" .. page_info.total_pages .. "]\n\n"
    
    if #transactions == 0 then
        text = text .. "No transactions found.\n"
    else
        for _, trans in ipairs(transactions) do
            text = text .. pda_guide:format_transaction(trans) .. "\n\n"
        end
    end
    
    return text
end

-- Show full transaction interface
function transaction_ui:show_full_interface()
    local page_data = pda_guide:generate_guide_page()
    
    local text = ""
    
    -- Header
    text = text .. "╔════════════════════════════════════╗\n"
    text = text .. "║     FINANCIAL TRACKING SYSTEM      ║\n"
    text = text .. "╚════════════════════════════════════╝\n\n"
    
    -- Summary
    local summary = page_data.summary
    text = text .. "[b]ACCOUNT OVERVIEW[c]\n"
    text = text .. "Income: [g]" .. summary.formatted_income .. "[c]\n"
    text = text .. "Expenses: [r]" .. summary.formatted_expenses .. "[c]\n"
    text = text .. "Balance: " .. summary.formatted_balance .. "\n\n"
    
    -- Transaction list
    text = text .. "[b]RECENT TRANSACTIONS[c]\n"
    text = text .. "(Page " .. page_data.page_info.current_page .. "/" .. page_data.page_info.total_pages .. ")\n\n"
    
    if #page_data.transactions == 0 then
        text = text .. "No transactions recorded yet.\n"
    else
        for _, trans in ipairs(page_data.transactions) do
            text = text .. pda_guide:format_transaction(trans) .. "\n"
        end
    end
    
    return text
end

-- Create notification
function transaction_ui:show_notification(title, message)
    printf("[TRANSACTION MOD] NOTIFICATION: %s - %s", title, message)
    -- This would integrate with Anomaly's notification system
end

-- Show transaction added notification
function transaction_ui:notify_transaction_added(amount, category, description)
    local type_str = (amount > 0) and "Income" or "Expense"
    local type_color = (amount > 0) and "[g]" or "[r]"
    
    local msg = string.format(
        "%s%s %d RU[c] - %s\n%s",
        type_color,
        type_str,
        math.abs(amount),
        category,
        description
    )
    
    self:show_notification("Transaction Recorded", msg)
end

-- Build category filter buttons
function transaction_ui:get_category_buttons()
    local buttons = {
        {name = "All", id = nil},
        {name = "Weapons", id = "weapons"},
        {name = "Medical", id = "medical"},
        {name = "Repairs", id = "repairs"},
        {name = "Supplies", id = "supplies"},
        {name = "Misc", id = "misc"},
        {name = "Quests", id = "quests"}
    }
    return buttons
end

-- Format currency
function transaction_ui:format_currency(amount, show_sign)
    if show_sign then
        return string.format("%+d RU", amount)
    else
        return string.format("%d RU", math.abs(amount))
    end
end

-- Color code by transaction type
function transaction_ui:get_type_color(transaction_type)
    if transaction_type == "income" then
        return "[g]" -- Green
    else
        return "[r]" -- Red
    end
end

return transaction_ui
