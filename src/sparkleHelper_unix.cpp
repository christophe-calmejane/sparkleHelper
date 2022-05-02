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

void Sparkle::init(std::string const& /*internalNumber*/, std::string const& /*signature*/) noexcept
{
	//
}

void Sparkle::start() noexcept
{
	if (!_initialized)
	{
		return;
	}

	_started = true;
}

void Sparkle::setAutomaticCheckForUpdates(bool const checkForUpdates) noexcept
{
	if (!_initialized)
	{
		return;
	}

	_checkForUpdates = checkForUpdates;
}

void Sparkle::setAppcastUrl(std::string const& appcastUrl) noexcept
{
	if (!_initialized)
	{
		return;
	}

	_appcastUrl = appcastUrl;
}

void Sparkle::manualCheckForUpdate() noexcept
{
	if (!_initialized)
	{
		return;
	}
}

Sparkle::~Sparkle() noexcept
{
	//
}
