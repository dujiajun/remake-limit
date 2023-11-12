class CreateUserDeletionLogs < ActiveRecord::Migration[7.0]
    def up
        create_table :user_deletion_logs do |t|
            t.integer :user_id
            t.string :username
            t.string :email
            t.string :jaccount_name
            t.string :jaccount_id
            t.integer :silence_count
            t.integer :suspend_count
    
            t.timestamps
        end
        PluginStoreRow.where(plugin_name:'remake-limit-penalty-history').each do |row|
            email = row.key
            data = JSON.parse(row.value)
            data.each do |key, value|
                user_id = key.to_i
                record = UserDeletionLog.find_or_initialize_by(
                    user_id: user_id,
                )
                record.email = email
                record.silence_count = value['silenced']
                record.suspend_count = value['suspended']
                record.save!
            end
        end
        PluginStoreRow.where(plugin_name:'remake-limit').each do |row|
            record = UserDeletionLog.find_or_initialize_by(email: row.key)
            record.created_at = row.value
            record.save!
        end
    end
  end