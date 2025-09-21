:if expand('%:p:h') !=# getcwd()
:  0put ='package ' . expand('%:p:h:gs?[/\\]?.?')[len(getcwd()) + 1 :] . ';'
:  1put =''
:endif
/**
 *
 */
public class <%= expand("%:t:r") %> {
	<+CURSOR+>
}
