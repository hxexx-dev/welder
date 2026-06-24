--!strict
type Logger = { log: (...any) -> (), warn: (...any) -> () }

local Logger: Logger = {} :: Logger

Logger.log = function(...: any): ()
	print(`[Welder:INFO]:`, ...)
end
Logger.warn = function(...: any): ()
	warn(`[Welder:WARN]:`, ...)
end

return Logger
