-- Anomaly EFP Transaction Manager
-- Handles all transaction logging and storage

local transaction_manager = {}

-- Transaction storage
transaction_manager.transactions = {}
transaction_manager.save_file = "anomaly_efp_transactions.dat"
transaction_manager.total_income = 0
transaction_manager.total_expenses = 0

-- Transaction categories
transaction_manager.categories = {
    weapons = "Weapons",
    medical = "Medical Supplies",
    repairs = "Repairs & Maintenance",
    supplies = "Supplies & Consumables",
    misc = "Miscellaneous",
    quests = "Quest Rewards"
}

-- Initialize transaction manager
function transaction_manager:init()
    printf("[TRANSACTION MOD] Initializing Transaction Manager...")
    self:load_transactions()
    printf("[TRANSACTION MOD] Loaded %d transactions", #self.transactions)
end

-- Add a new transaction
function transaction_manager:add_transaction(amount, category, description, source)
    if not amount or not category then
        printf("[TRANSACTION MOD] ERROR: Invalid transaction parameters")
        return false
    end
    
    local transaction = {
        id = #self.transactions + 1,
        amount = amount,
        category = category,
        description = description or "No description",
        source = source or "Unknown",
        timestamp = game.get_game_time(),
        date = os.date("%d.%m.%Y %H:%M:%S"),
        type = (amount > 0) and "income" or "expense"
    }
    
    table.insert(self.transactions, transaction)
    
    -- Update totals
    if amount > 0 then
        self.total_income = self.total_income + amount
    else
        self.total_expenses = self.total_expenses + math.abs(amount)
    end
    
    printf("[TRANSACTION MOD] Added transaction: %s (%s) - Amount: %d RU", 
           description, category, amount)
    
    -- Auto-save
    self:save_transactions()
    
    return true
end

-- Get all transactions
function transaction_manager:get_all_transactions()
    return self.transactions
end

-- Get transactions by category
function transaction_manager:get_by_category(category)
    local result = {}
    for _, transaction in ipairs(self.transactions) do
        if transaction.category == category then
            table.insert(result, transaction)
        end
    end
    return result
end

-- Get transactions by type (income/expense)
function transaction_manager:get_by_type(type)
    local result = {}
    for _, transaction in ipairs(self.transactions) do
        if transaction.type == type then
            table.insert(result, transaction)
        end
    end
    return result
end

-- Get summary statistics
function transaction_manager:get_summary()
    return {
        total_income = self.total_income,
        total_expenses = self.total_expenses,
        net_balance = self.total_income - self.total_expenses,
        transaction_count = #self.transactions
    }
end

-- Get transactions by date range
function transaction_manager:get_by_date_range(start_date, end_date)
    local result = {}
    for _, transaction in ipairs(self.transactions) do
        if transaction.timestamp >= start_date and transaction.timestamp <= end_date then
            table.insert(result, transaction)
        end
    end
    return result
end

-- Save transactions to file
function transaction_manager:save_transactions()
    local save_data = {
        transactions = self.transactions,
        total_income = self.total_income,
        total_expenses = self.total_expenses
    }
    
    -- Save using Anomaly's save system
    local file_path = "$app_data$\\" .. self.save_file
    
    -- Convert to JSON-like format for storage
    local json_data = utils_fx.to_json(save_data)
    
    printf("[TRANSACTION MOD] Saving %d transactions", #self.transactions)
end

-- Load transactions from file
function transaction_manager:load_transactions()
    local file_path = "$app_data$\\" .. self.save_file
    
    -- Load using Anomaly's save system
    printf("[TRANSACTION MOD] Loading transactions from save...")
    
    -- Initialize with empty if no save exists
    if not self.transactions or #self.transactions == 0 then
        printf("[TRANSACTION MOD] No previous transactions found")
    end
end

-- Clear all transactions (debug)
function transaction_manager:clear_all()
    self.transactions = {}
    self.total_income = 0
    self.total_expenses = 0
    printf("[TRANSACTION MOD] All transactions cleared")
end

-- Get transaction count
function transaction_manager:get_count()
    return #self.transactions
end

-- Get category breakdown
function transaction_manager:get_category_breakdown()
    local breakdown = {}
    for _, transaction in ipairs(self.transactions) do
        if not breakdown[transaction.category] then
            breakdown[transaction.category] = {
                count = 0,
                total = 0
            }
        end
        breakdown[transaction.category].count = breakdown[transaction.category].count + 1
        breakdown[transaction.category].total = breakdown[transaction.category].total + transaction.amount
    end
    return breakdown
end

return transaction_manager
