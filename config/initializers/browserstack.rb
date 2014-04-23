# Some stuff relating to browserstack.
ENV['BS_USERNAME'] ||= 'mark476'
ENV['BS_AUTHKEY'] ||= 'saKB1n6xeWQXNBgP6oFZ'

BS_BROWSERS = {
	'Chrome (Mac)' => {
		browser: 'Chrome',
		os: 'OS X',
		os_version: 'Mavericks',
		resolutions: ['1024x768', '1280x960', '1280x1024', '1600x1200', '1920x1080']
	}, 
	'Chrome (PC)' => {
		browser: 'Chrome',
		os: 'Windows',
		os_version: '8.1',
		resolutions: ['1024x768', '1280x800', '1280x1024', '1366x768', '1440x900', '1680x1050', '1600x1200', '1920x1200', '1920x1080', '2048x1536']
	},
	'Firefox (Mac)' => {
		browser: 'Firefox',
		os: 'OS X',
		os_version: 'Mavericks',
		resolutions: ['1024x768', '1280x960', '1280x1024', '1600x1200', '1920x1080']
	},
	'Firefox (PC)' => {
		browser: 'Firefox',
		os: 'Windows',
		os_version: '8.1',
		resolutions: ['1024x768', '1280x800', '1280x1024', '1366x768', '1440x900', '1680x1050', '1600x1200', '1920x1200', '1920x1080', '2048x1536']
	},
	'Safari' => {
		browser: 'Safari',
		os: 'OS X',
		os_version: 'Mavericks',
		resolutions: ['1024x768', '1280x960', '1280x1024', '1600x1200', '1920x1080']
	},
	'IE8' => {
		browser: 'IE',
		browser_version: '8.0',
		os: 'Windows',
		os_version: '7',
		resolutions: ['800x600', '1024x768', '1280x1024']
	},
	'IE9' => {
		browser: 'IE',
		browser_version: '9.0',
		os: 'Windows',
		os_version: '7',
		resolutions: ['800x600', '1024x768', '1280x1024']
	},
	'IE10' => {
		browser: 'IE',
		browser_version: '10.0',
		os: 'Windows',
		os_version: '7',
		resolutions: ['800x600', '1024x768', '1280x1024']
	}
}

BS_DEVICES = {
	'iPad' => {
		browserName: 'iPad',
		platform: 'MAC',
		devices: ['iPad 2', 'iPad 3rd (6.0)', 'iPad 3rd (7.0)']
	},
	'iPhone' => {
		browserName: 'iPhone',
		platform: 'MAC',
		devices: ['iPhone 4S', 'iPhone 4S (6.0)', 'iPhone 5', 'iPhone 5S']
	},
	'Android' => {}
}
