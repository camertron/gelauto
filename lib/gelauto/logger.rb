module Gelauto
  module Logger
    class << self
      def debug(str)
        Gelauto.logger.debug(fmt(str))
      end

      def info(str)
        Gelauto.logger.info(fmt(str))
      end

      def warn(str)
        Gelauto.logger.warn(fmt(str))
      end

      def error(str)
        Gelauto.logger.error(fmt(str))
      end

      def fatal(str)
        Gelauto.logger.fatal(fmt(str))
      end

      private

      def fmt(str)
        "[Gelauto] #{str}"
      end
    end
  end
end
