class SmartIoC::Railtie < Rails::Railtie
  initializer "smart_ioc.watching_for_bean_changes" do |app|
    if app.config.reload_classes_only_on_change
      bean_file_locations = SmartIoC::BeanLocations.get_all_bean_files

      reloader = app.config.file_watcher.new(bean_file_locations) do
        SmartIoC.container.force_clear_scopes
      end

      app.config.to_prepare { reloader.execute_if_updated }
    end
  end

  console do
    module Rails::ConsoleMethods
      alias :old_reload! :reload!

      def reload!(print = true)
        SmartIoC.container.force_clear_scopes
        old_reload!(print = true)
      end
    end
  end
end