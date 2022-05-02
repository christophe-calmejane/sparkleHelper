/*
* MIT License
*
* Copyright (C) 2020-2022, Christophe Calmejane
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

#include "sparkleHelper/sparkleHelper.hpp"

#include <winsparkle.h>
#include <Windows.h>

#include <string>
#include <stdexcept>

inline std::wstring utf8ToWideChar(std::string const& str)
{
	auto const sizeHint = str.size(); // WideChar size cannot exceed the number of multi-bytes
	auto result = std::wstring(static_cast<std::wstring::size_type>(sizeHint), std::wstring::value_type{ 0 }); // Brace-initialization constructor prevents the use of {}

	// Try to convert
	auto const convertedLength = MultiByteToWideChar(CP_UTF8, 0, str.data(), static_cast<int>(str.size()), result.data(), static_cast<int>(sizeHint));
	if (convertedLength == 0)
	{
		throw std::invalid_argument("Failed to convert from MultiByte to WideChar");
	}

	// Adjust size
	result.resize(convertedLength);

	return result;
}

void Sparkle::init(std::string const& internalNumber, std::string const& signature) noexcept
{
	try
	{
		// Set Language ID
		win_sparkle_set_langid(::GetThreadUILanguage());
		// Set our DSA public key
		win_sparkle_set_dsa_pub_pem(signature.c_str());
		// Set internal number
		try
		{
			win_sparkle_set_app_build_version(utf8ToWideChar(internalNumber).c_str());
		}
		catch (std::invalid_argument const&)
		{
		}

		// Set callbacks to handle application shutdown when an update is starting
		win_sparkle_set_can_shutdown_callback(
			[]() -> int
			{
				auto const& sparkle = getInstance();
				if (sparkle._isShutdownAllowedHandler)
				{
					return static_cast<int>(sparkle._isShutdownAllowedHandler());
				}
				return 1;
			});
		win_sparkle_set_shutdown_request_callback(
			[]()
			{
				auto const& sparkle = getInstance();
				if (sparkle._shutdownRequestHandler)
				{
					sparkle._shutdownRequestHandler();
				}
			});
		win_sparkle_set_did_find_update_callback(
			[]()
			{
				auto const& sparkle = getInstance();
				if (sparkle._logHandler)
				{
					sparkle._logHandler("A new update has been found", LogLevel::Info);
				}
			});
		win_sparkle_set_error_callback(
			[]()
			{
				auto const& sparkle = getInstance();
				if (sparkle._logHandler)
				{
					sparkle._logHandler("Automatic update failed", LogLevel::Warn);
				}
				if (sparkle._updateFailedHandler)
				{
					sparkle._updateFailedHandler();
				}
			});

		// Get current Check For Updates value
		_checkForUpdates = static_cast<bool>(win_sparkle_get_automatic_check_for_updates());

		_initialized = true;
	}
	catch (...)
	{
	}
}

void Sparkle::start() noexcept
{
	if (!_initialized)
	{
		return;
	}

	win_sparkle_init();

	_started = true;
}

void Sparkle::setAutomaticCheckForUpdates(bool const checkForUpdates) noexcept
{
	if (!_initialized)
	{
		return;
	}

	try
	{
		// Set Automatic Check For Updates
		win_sparkle_set_automatic_check_for_updates(static_cast<int>(checkForUpdates));

		// If switching to CheckForUpdates, check right now
		if (checkForUpdates && _started)
		{
			win_sparkle_check_update_without_ui();
		}

		_checkForUpdates = checkForUpdates;
	}
	catch (...)
	{
	}
}

void Sparkle::setAppcastUrl(std::string const& appcastUrl) noexcept
{
	if (!_initialized)
	{
		return;
	}

	try
	{
		// Set Appcast URL
		win_sparkle_set_appcast_url(appcastUrl.c_str());
		if (appcastUrl != _appcastUrl && _started && _checkForUpdates)
		{
			win_sparkle_check_update_without_ui();
		}

		_appcastUrl = appcastUrl;
	}
	catch (...)
	{
	}
}

void Sparkle::manualCheckForUpdate() noexcept
{
	if (!_initialized)
	{
		return;
	}

	if (_started)
	{
		win_sparkle_check_update_with_ui();
	}
}

Sparkle::~Sparkle() noexcept
{
	win_sparkle_cleanup();
}
