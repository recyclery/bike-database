class RemoveUnusedColumnsFromClients < ActiveRecord::Migration[5.0]
  def change
    remove_column :clients, :number_of_calls
    remove_column :clients, :application_date_bkp
    remove_column :clients, :pickup_date_bkp
  end
end
