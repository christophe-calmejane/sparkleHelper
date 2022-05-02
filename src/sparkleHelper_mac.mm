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

#import <Sparkle/Sparkle.h>
#import <Foundation/Foundation.h>

/** std::string to NSString conversion */
static inline NSString* getNSString(std::string const& cString)
{
	return [NSString stringWithCString:cString.c_str() encoding:NSUTF8StringEncoding];
}

/** NSString to std::string conversion */
static inline std::string getStdString(NSString* nsString)
{
	return std::string{ [nsString UTF8String] };
}

@interface SparkleDelegate<SUUpdaterDelegate> : NSObject
+ (SparkleDelegate*)getInstance;
@end

@implementation SparkleDelegate

+ (SparkleDelegate*)getInstance {
	static SparkleDelegate* s_Instance = nil;

	@synchronized(self)
	{
		if (s_Instance == nil)
		{
			s_Instance = [[self alloc] init];
		}
	}

	return s_Instance;
}

- (BOOL)updaterMayCheckForUpdates:(SUUpdater*)updater {
	return TRUE;
}

- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater*)updater {
	return TRUE;
}

- (void)updater:(SUUpdater*)updater didFindValidUpdate:(SUAppcastItem*)item {
	auto const& handler = Sparkle::getInstance().getLogHandler();
	if (handler)
	{
		handler("A new update has been found", Sparkle::LogLevel::Info);
	}
}

- (void)updaterDidNotFindUpdate:(SUUpdater*)updater {
}

- (BOOL)updaterShouldShowUpdateAlertForScheduledUpdate:(SUUpdater*)updater forItem:(SUAppcastItem*)item {
	return TRUE;
}

- (void)updater:(SUUpdater*)updater willDownloadUpdate:(SUAppcastItem*)item withRequest:(NSMutableURLRequest*)request {
}

- (void)updater:(SUUpdater*)updater didDownloadUpdate:(SUAppcastItem*)item {
}

- (void)updater:(SUUpdater*)updater failedToDownloadUpdate:(SUAppcastItem*)item error:(NSError*)error {
}

- (void)updaterWillShowModalAlert:(SUUpdater*)updater {
}

- (void)updater:(SUUpdater*)updater willExtractUpdate:(SUAppcastItem*)item {
}

- (void)updater:(SUUpdater*)updater didExtractUpdate:(SUAppcastItem*)item {
}

- (void)updater:(SUUpdater*)updater willInstallUpdate:(SUAppcastItem*)item {
}

- (void)updater:(SUUpdater*)updater didAbortWithError:(NSError*)error {
	{
		auto const& handler = Sparkle::getInstance().getLogHandler();
		if (handler)
		{
			handler(std::string{ "Automatic update failed: " } + getStdString([error description]), Sparkle::LogLevel::Warn);
		}
	}
	{
		auto const& handler = Sparkle::getInstance().getUpdateFailedHandler();
		if (handler)
		{
			handler();
		}
	}
}

- (void)updater:(SUUpdater*)updater willInstallUpdateOnQuit:(SUAppcastItem*)item immediateInstallationInvocation:(NSInvocation*)invocation {
}

@end

void Sparkle::init(std::string const& /*internalNumber*/, std::string const& signature) noexcept
{
	auto* const updater = [SUUpdater sharedUpdater];

	updater.delegate = static_cast<id<SUUpdaterDelegate>>([SparkleDelegate getInstance]);

	// Get current Check For Updates value
	_checkForUpdates = updater.automaticallyChecksForUpdates;

	_initialized = true;
}

void Sparkle::start() noexcept
{
	if (!_initialized)
	{
		return;
	}

	// Start updater
	auto* const updater = [SUUpdater sharedUpdater];
	[updater resetUpdateCycle];
	[updater checkForUpdatesInBackground];

	_started = true;
}

void Sparkle::setAutomaticCheckForUpdates(bool const checkForUpdates) noexcept
{
	if (!_initialized)
	{
		return;
	}

	// Set Automatic Check For Updates
	auto* const updater = [SUUpdater sharedUpdater];
	updater.automaticallyChecksForUpdates = checkForUpdates;

	// If switching to CheckForUpdates, check right now
	if (checkForUpdates && _started)
	{
		[updater resetUpdateCycle];
		[updater checkForUpdatesInBackground];
	}

	_checkForUpdates = checkForUpdates;
}

void Sparkle::setAppcastUrl(std::string const& appcastUrl) noexcept
{
	if (!_initialized)
	{
		return;
	}

	// Set Appcast URL
	auto* const updater = [SUUpdater sharedUpdater];
	updater.feedURL = [NSURL URLWithString:getNSString(appcastUrl)];

	if (appcastUrl != _appcastUrl && _started && _checkForUpdates)
	{
		[updater resetUpdateCycle];
		[updater checkForUpdatesInBackground];
	}

	_appcastUrl = appcastUrl;
}

void Sparkle::manualCheckForUpdate() noexcept
{
	if (!_initialized)
	{
		return;
	}

	auto* const updater = [SUUpdater sharedUpdater];
	[updater checkForUpdatesInBackground];
}

Sparkle::~Sparkle() noexcept
{
	// Nothing to do
}
