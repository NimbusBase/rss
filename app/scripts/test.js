QUnit.begin(function(){
	test('get rss from url',function(){
		var url = Reader.get_rss('techcrun.com');
		ok(1, 'Rss retriving result:'+url);
	});

	test( "a test", 2, function() {
	  function calc( x, operation ) {
	    return operation( x );
	  }
	 
	  var result = calc( 2, function( x ) {
	    ok( true, "calc() calls operation function" );
	    return x * x;
	  });
	 
	  equal( result, 4, "2 square equals 4" );
	});

	test('get feeds',function(){

		ok(1,'feed content');
	});

	test('get icon',function(){
		
	})
});

