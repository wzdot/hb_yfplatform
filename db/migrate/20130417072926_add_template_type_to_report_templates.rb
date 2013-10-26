class AddTemplateTypeToReportTemplates < ActiveRecord::Migration
  def change
    add_column :report_templates, :template_type, :integer, :default => 0
  end
end
