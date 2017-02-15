/**
 * @singleton
 * @presideservice
 *
 */
component {

	/**
	 * @emailServiceProviderService.inject emailServiceProviderService
	 *
	 */
	public any function init( required any emailServiceProviderService ) {
		_setEmailServiceProviderService( arguments.emailServiceProviderService );

		return this;
	}

// PUBLIC API METHODS
	public boolean function validatePostHookSignature(
		  required numeric timestamp
		, required string  token
		, required string  signature
	) {
		var encryptionKey       = _getApiKey();
		var encryptionData      = arguments.timestamp & arguments.token;
		var calculatedSignature = _hexEncodedSha256( encryptionData, encryptionKey );

		return arguments.signature == calculatedSignature;
	}

// PRIVATE HELPERS
	private string function _getApiKey(){
		return _getSettings().mailgun_api_key;
	}

	private struct function _getSettings(){
		if ( !request.keyExists( "_mailgunServiceProviderSettings" ) ) {
			var settings = _getEmailServiceProviderService().getProviderSettings( "mailgun" );

			request._mailgunServiceProviderSettings = {
				  mailgun_api_key        = settings.mailgun_api_key        ?: ""
				, mailgun_default_domain = settings.mailgun_default_domain ?: ""
				, mailgun_test_mode      = settings.mailgun_test_mode      ?: ""
			};
		}

		return request._mailgunServiceProviderSettings;
	}

	public string function _hexEncodedSha256( required string data, required string key ) {
		var secret = CreateObject( "java", "javax.crypto.spec.SecretKeySpec" ).Init( arguments.key.GetBytes(), "HmacSHA256" );
		var mac    = createObject( "java", "javax.crypto.Mac" ).getInstance( "HmacSHA256" );

		mac.init( secret );

		return _byteArrayToHex( mac.doFinal( arguments.data.GetBytes() ) );

	}

	public string function _byteArrayToHex( required any byteArray ) {
		var hexBytes = [];
		for( var byte in arguments.byteArray ) {
			var unsignedByte = bitAnd( byte, 255 );
			var hexChar      = FormatBaseN( unsignedByte, 16 );

			if ( unsignedByte < 16 ) {
				hexChar = "0" & hexChar;
			}
			hexBytes.append( hexChar );
		}

		return hexBytes.toList( "" );
	}

	private any function _getEmailServiceProviderService() {
		return _emailServiceProviderService;
	}
	private void function _setEmailServiceProviderService( required any emailServiceProviderService ) {
		_emailServiceProviderService = arguments.emailServiceProviderService;
	}
}