$ ->

	$('#search-button').click ->
		$('#search-form').slideDown 'fast',  -> $('#search-field').focus()
	
	$('#search-field').blur ->
		if $(this).val is "" then $('#search-form').slideUp 'fast'
				
	$('.contact-form').submit (e) ->
		
		$.ajax
			type: "POST"
			url: "/about/message"
			data: $('.contact-form').serialize()
			dataType: "json"
			beforeSend: ->
				#alert('before')
			
			error: (jqXHR, textStatus, errorThrown) ->
				$('.contact-form').fadeOut ->
					$('#contact-form-area').html("<div id='contact-message'><p>Ocorreu um problema ao enviar a mensagem, por favor tente novamente mais tarde ou envie um email diretamente para guilherme.defreitas@gmail.com.</p><p>Obrigado!</p></div>")
					$('#contact-message').fadeIn()	
			
			success: (data) ->
				$('.contact-form').fadeOut ->
					$('#contact-form-area').html("<div id='contact-message'><p>Mensagem enviada com sucesso. Obrigado!</p></div>")
					$('#contact-message').fadeIn()
		
		e.preventDefault()
