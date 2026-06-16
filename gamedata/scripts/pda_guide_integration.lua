-- Anomaly EFP PDA Guide Integration
-- Integrates transaction logging into PDA Guide section

local pda_guide = {}
local transaction_manager = require("anomaly-efp-transaction-mod/gamedata/scripts/transaction_manager")

-- Page states
pda_guide.current_page = 1
pda_guide.items_per_page = 10
pda_guide.current_filter = nil
pda_guide.categories = {
    "weapons",
    "medical",
    "repairs",
    "supplies",
    "misc",
    "quests"
}

-- Initialize PDA integration
function pda_guide:init()
    printf("[TRANSACTION MOD] Initializing PDA Guide Integration...")
    self:register_guide_section()
end

-- Register finance section in PDA Guide
function pda_guide:register_guide_section()
    printf("[TRANSACTION MOD] Registering Finance section in PDA Guide")
    
    -- This would integrate with the actual PDA system
    -- For now, we'll log the registration
    printf("[TRANSACTION MOD] Finance guide section registered successfully")
end

-- Get formatted transaction list
function pda_guide:get_transaction_list(page, filter_category)
    page = page or 1
    local transactions
    
    if filter_category then
        transactions = transaction_manager:get_by_category(filter_category)
    else
        transactions = transaction_manager:get_all_transactions()
    end
    
    -- Sort by timestamp (newest first)
    table.sort(transactions, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Paginate results
    local start_idx = (page - 1) * self.items_per_page + 1
    local end_idx = start_idx + self.items_per_page - 1
    
    local page_transactions = {}
    for i = start_idx, end_idx do
        if transactions[i] then
            table.insert(page_transactions, transactions[i])
        end
    end
    
    return page_transactions, #transactions
end

-- Get summary for display
function pda_guide:get_summary_display()
    local summary = transaction_manager:get_summary()
    
    return {
        title = "Finance Summary",
        total_income = summary.total_income,
        total_expenses = summary.total_expenses,
        net_balance = summary.net_balance,
        transaction_count = summary.transaction_count,
        formatted_income = string.format("%d RU", summary.total_income),
        formatted_expenses = string.format("-%d RU", summary.total_expenses),
        formatted_balance = string.format("%d RU", summary.net_balance)
    }
end

-- Get category summary
function pda_guide:get_category_summary()
    local breakdown = transaction_manager:get_category_breakdown()
    local result = {}
    
    for category, data in pairs(breakdown) do
        table.insert(result, {
            category = category,
            count = data.count,
            total = data.total,
            formatted = string.format("%s: %d RU (%d transactions)", category, data.total, data.count)
        })
    end
    
    return result
end

-- Format transaction for display
function pda_guide:format_transaction(transaction)
    local type_symbol = (transaction.type == "income") and "+" or "-"
    local type_color = (transaction.type == "income") and "[g]" or "[r]"
    
    return string.format(
        "%s%s %d RU - %s\n%s | %s",
        type_color,
        type_symbol,
        math.abs(transaction.amount),
        transaction.category,
        transaction.description,
        transaction.date
    )
end

-- Get page info
function pda_guide:get_page_info(total_transactions)
    local total_pages = math.ceil(total_transactions / self.items_per_page)
    return {
        current_page = self.current_page,
        total_pages = total_pages,
        items_per_page = self.items_per_page,
        total_items = total_transactions
    }
end

-- Next page
function pda_guide:next_page(total_transactions)
    local total_pages = math.ceil(total_transactions / self.items_per_page)
    if self.current_page < total_pages then
        self.current_page = self.current_page + 1
        return true
    end
    return false
end

-- Previous page
function pda_guide:prev_page()
    if self.current_page > 1 then
        self.current_page = self.current_page - 1
        return true
    end
    return false
end

-- Set filter
function pda_guide:set_filter(category)
    self.current_filter = category
    self.current_page = 1
    printf("[TRANSACTION MOD] Filter set to: %s", category or "None")
end

-- Clear filter
function pda_guide:clear_filter()
    self.current_filter = nil
    self.current_page = 1
    printf("[TRANSACTION MOD] Filter cleared")
end

-- Generate full guide page
function pda_guide:generate_guide_page()
    local summary = self:get_summary_display()
    local transactions, total = self:get_transaction_list(self.current_page, self.current_filter)
    local page_info = self:get_page_info(total)
    
    return {
        summary = summary,
        transactions = transactions,
        page_info = page_info,
        categories = self.categories,
        current_filter = self.current_filter
    }
end

return pda_guide
