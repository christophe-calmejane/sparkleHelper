/*
* MIT License
*
* Copyright (c) 2020'21 Christophe Calmejane
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#pragma once

#include <string>
#include <functional>

class Sparkle final
{
public:
	enum class LogLevel
	{
		Info = 0,
		Warn = 1,
		Error = 2,
	};

	using IsShutdownAllowedHandler = std::function<bool()>;
	using ShutdownRequestHandler = std::function<void()>;
	using LogHandler = std::function<void(std::string const& message, LogLevel const level)>;
	using UpdateFailedHandler = std::function<void()>;

	static Sparkle& getInstance() noexcept
	{
		static auto s_Instance = Sparkle{};
		return s_Instance;
	}

	/* Initialization methods */
	// Must be called before any other methods, and as soon as possible
	void init(std::string const& internalNumber, std::string const& signature) noexcept;
	// Must be called to start the background check process, but not before the UI is visible and configuration methods have been called
	void start() noexcept;

	/* Configuration methods */
	void setAutomaticCheckForUpdates(bool const checkForUpdates) noexcept;
	void setAppcastUrl(std::string const& appcastUrl) noexcept;
	void setIsShutdownAllowedHandler(IsShutdownAllowedHandler const& isShutdownAllowedHandler) noexcept
	{
		_isShutdownAllowedHandler = isShutdownAllowedHandler;
	}
	void setShutdownRequestHandler(ShutdownRequestHandler const& shutdownRequestHandler) noexcept
	{
		_shutdownRequestHandler = shutdownRequestHandler;
	}
	void setLogHandler(LogHandler const& logHandler) noexcept
	{
		_logHandler = logHandler;
	}
	LogHandler const& getLogHandler() const noexcept
	{
		return _logHandler;
	}
	void setUpdateFailedHandler(UpdateFailedHandler const& updateFailedHandler) noexcept
	{
		_updateFailedHandler = updateFailedHandler;
	}
	UpdateFailedHandler const& getUpdateFailedHandler() const noexcept
	{
		return _updateFailedHandler;
	}

	/* Requests methods */
	void manualCheckForUpdate() noexcept;

	// Deleted compiler auto-generated methods
	Sparkle(Sparkle&&) = delete;
	Sparkle(Sparkle const&) = delete;
	Sparkle& operator=(Sparkle const&) = delete;
	Sparkle& operator=(Sparkle&&) = delete;

private:
	/** Constructor */
	Sparkle() noexcept = default;

	/** Destructor */
	~Sparkle() noexcept;

	// Private members
	bool _initialized{ false };
	bool _started{ false };
	bool _checkForUpdates{ false };
	std::string _appcastUrl{};
	IsShutdownAllowedHandler _isShutdownAllowedHandler{ nullptr };
	ShutdownRequestHandler _shutdownRequestHandler{ nullptr };
	LogHandler _logHandler{ nullptr };
	UpdateFailedHandler _updateFailedHandler{ nullptr };
};
