-- Anomaly EFP Quest Rewards Integration
-- Automatically logs income when quests are completed

local quest_rewards = {}
local transaction_manager = require("anomaly-efp-transaction-mod/gamedata/scripts/transaction_manager")

-- Completed quests tracking
quest_rewards.completed_quests = {}

-- Initialize quest reward system
function quest_rewards:init()
    printf("[TRANSACTION MOD] Initializing Quest Rewards Tracker...")
    self:register_quest_callbacks()
end

-- Register quest completion callbacks
function quest_rewards:register_quest_callbacks()
    printf("[TRANSACTION MOD] Registering quest callbacks")
    -- This would hook into Anomaly's quest completion system
end

-- Handle quest completion
function quest_rewards:on_quest_complete(quest_id, reward_amount, quest_name)
    if not quest_id or not reward_amount then
        printf("[TRANSACTION MOD] ERROR: Invalid quest completion data")
        return false
    end
    
    -- Check if already logged
    if self.completed_quests[quest_id] then
        printf("[TRANSACTION MOD] Quest %s already logged", quest_id)
        return false
    end
    
    -- Log the reward
    local description = string.format("Quest Completed: %s", quest_name or quest_id)
    
    transaction_manager:add_transaction(
        reward_amount,
        "quests",
        description,
        "quest_reward"
    )
    
    -- Mark as completed
    self.completed_quests[quest_id] = {
        quest_name = quest_name,
        reward_amount = reward_amount,
        completed_at = game.get_game_time(),
        date = os.date("%d.%m.%Y %H:%M:%S")
    }
    
    printf("[TRANSACTION MOD] Quest reward logged: %s - %d RU", quest_name or quest_id, reward_amount)
    
    return true
end

-- Get completed quests
function quest_rewards:get_completed_quests()
    return self.completed_quests
end

-- Get quest reward total
function quest_rewards:get_total_quest_rewards()
    local total = 0
    local transactions = transaction_manager:get_by_category("quests")
    
    for _, trans in ipairs(transactions) do
        total = total + trans.amount
    end
    
    return total
end

-- Simulate quest completion (for testing)
function quest_rewards:test_quest_completion(reward_amount)
    local quest_id = "test_quest_" .. tostring(#self.completed_quests + 1)
    local quest_name = "Test Quest " .. tostring(#self.completed_quests + 1)
    
    self:on_quest_complete(quest_id, reward_amount, quest_name)
end

return quest_rewards
