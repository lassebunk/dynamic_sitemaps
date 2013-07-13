module DynamicSitemaps
  class Logger
    class << self
      def info(message)
        show message
        Rails.logger.info message
      end

      def warn(message)
        show message
        Rails.logger.warn message
      end

      # Shows the message using puts unless testing.
      def show(message)
        unless Rails.env.test?
          puts message
        end
      end
    end
  end
end