<%!
from asciidoxy.generator.templates.helpers import h1
from asciidoxy.generator.templates.cpp.helpers import CppTemplateHelper
from html import escape
%>
[%unbreakable]
****
[%autofit]
[#${element.id},reftext='${element.full_name}']
[source,cpp,subs="-specialchars,macros+"]
----
${escape(CppTemplateHelper(api).method_signature(element))}
----
${element.brief}

${element.description}
****
