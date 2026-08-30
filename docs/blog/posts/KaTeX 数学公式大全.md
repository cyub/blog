---
title: KaTeX 数学公式大全
authors:
  - Tinker
tags:
  - 编码与协议/KaTeX
categories:
  - 翻译
  - 编码与协议
date: 2026-08-08 10:50:00
---

> **编者按**：KaTeX 是一款基于 Donald Knuth 的 TeX 系统构建的高性能网页数学排版引擎，能够为数学公式与物理符号提供细致而快速的渲染效果。笔者日常深度使用 Obsidian，该笔记软件原生支持 KaTeX，故特此翻译并整理本文，旨在系统介绍 KaTeX 所支持的 TeX 语法。本文译自[官方函数列表文档](https://katex.org/docs/supported.html)。


这是 KaTeX 支持的 TeX 函数列表，按逻辑分组排序。

<!-- more -->

## 重音符号

||||
|:----------------------------|:----------------------------------------------------|:------
|$a'$ `a'`  |$\tilde{a}$ `\tilde{a}`|$\mathring{g}$ `\mathring{g}`
|$a''$ `a''`|$\widetilde{ac}$ `\widetilde{ac}`  |$\overgroup{AB}$ `\overgroup{AB}`
|$a^{\prime}$ `a^{\prime}` |$\utilde{AB}$ `\utilde{AB}`  |$\undergroup{AB}$ `\undergroup{AB}`
|$\acute{a}$ `\acute{a}`|$\vec{F}$ `\vec{F}` |$\Overrightarrow{AB}$ `\Overrightarrow{AB}`
|$\bar{y}$ `\bar{y}` |$\overleftarrow{AB}$ `\overleftarrow{AB}`|$\overrightarrow{AB}$ `\overrightarrow{AB}`
|$\breve{a}$ `\breve{a}`|$\underleftarrow{AB}$ `\underleftarrow{AB}` |$\underrightarrow{AB}$ `\underrightarrow{AB}`
|$\check{a}$ `\check{a}`|$\overleftharpoon{ac}$ `\overleftharpoon{ac}`  |$\overrightharpoon{ac}$ `\overrightharpoon{ac}`
|$\dot{a}$ `\dot{a}` |$\overleftrightarrow{AB}$ `\overleftrightarrow{AB}`  |$\overbrace{AB}$ `\overbrace{AB}`
|$\ddot{a}$ `\ddot{a}`  |$\underleftrightarrow{AB}$ `\underleftrightarrow{AB}`|$\underbrace{AB}$ `\underbrace{AB}`
|$\dddot{a}$ `\dddot{a}`|$\overline{AB}$ `\overline{AB}` |$\overbracket{AB}$ `\overbracket{AB}`
|$\ddddot{a}$ `\ddddot{a}`|$\underline{AB}$ `\underline{AB}`  |$\underbracket{AB}$ `\underbracket{AB}`
|$\grave{a}$ `\grave{a}`|$\underbar{X}$ `\underbar{X}`|$\overlinesegment{AB}$ `\overlinesegment{AB}`
|$\hat{\theta}$ `\hat{\theta}`|$\widecheck{ac}$ `\widecheck{ac}`  |$\underlinesegment{AB}$ `\underlinesegment{AB}`
||$\widehat{ac}$ `\widehat{ac}`|

***在 \text{…} 内部使用的重音函数***

|||||
|:---------------------|:---------------------|:---------------------|:-----
|$\text{\'{a}}$ `\'{a}`|$\text{\~{a}}$ `\~{a}`|$\text{\.{a}}$ `\.{a}`|$\text{\H{a}}$ `\H{a}`
|$\text{\`{a}}$ <code>\\`{a}</code>|$\text{\={a}}$ `\={a}`|$\text{\"{a}}$ `\"{a}`|$\text{\v{a}}$ `\v{a}`
|$\text{\^{a}}$ `\^{a}`|$\text{\u{a}}$ `\u{a}`|$\text{\r{a}}$ `\r{a}`|

另请参阅[字母与 Unicode](#字母与-unicode)。

## 定界符

||||||
|:-----------------------------------|:---------------------------------------|:----------|:-------------------------------------------------------|:-----
|$(~)$ `( )` |$\lparen~\rparen$ `\lparen`<br>$~~~~$`\rparen`|$⌈~⌉$ `⌈ ⌉`|$\lceil~\rceil$ `\lceil`<br>$~~~~~$`\rceil`  |$\uparrow$ `\uparrow`
|$[~]$ `[ ]` |$\lbrack~\rbrack$ `\lbrack`<br>$~~~~$`\rbrack`|$⌊~⌋$ `⌊ ⌋`|$\lfloor~\rfloor$ `\lfloor`<br>$~~~~~$`\rfloor` |$\downarrow$ `\downarrow`
|$\{ \}$ `\{ \}`|$\lbrace \rbrace$ `\lbrace`<br>$~~~~$`\rbrace`|$⎰⎱$ `⎰⎱`  |$\lmoustache \rmoustache$ `\lmoustache`<br>$~~~~$`\rmoustache`|$\updownarrow$ `\updownarrow`
|$⟨~⟩$ `⟨ ⟩` |$\langle~\rangle$ `\langle`<br>$~~~~$`\rangle`|$⟮~⟯$ `⟮ ⟯`|$\lgroup~\rgroup$ `\lgroup`<br>$~~~~~$`\rgroup` |$\Uparrow$ `\Uparrow`
|$\vert$ <code>&#124;</code> |$\vert$ `\vert` |$┌ ┐$ `┌ ┐`|$\ulcorner \urcorner$ `\ulcorner`<br>$~~~~$`\urcorner`  |$\Downarrow$ `\Downarrow`
|$\Vert$ <code>&#92;&#124;</code> |$\Vert$ `\Vert` |$└ ┘$ `└ ┘`|$\llcorner \lrcorner$ `\llcorner`<br>$~~~~$`\lrcorner`  |$\Updownarrow$ `\Updownarrow`
|$\lvert~\rvert$ `\lvert`<br>$~~~~$`\rvert`|$\lVert~\rVert$ `\lVert`<br>$~~~~~$`\rVert` |`\left.`|  `\right.` |$\backslash$ `\backslash`
|$\lang~\rang$ `\lang`<br>$~~~~$`\rang`|$\left\lt~\right\gt$ `\lt \gt`|$⟦~⟧$ `⟦ ⟧`|$\llbracket~\rrbracket$ `\llbracket`<br>$~~~~$`\rrbracket`|$/$ `/`
|$\lBrace~\rBrace$ `\lBrace \rBrace`

**定界符尺寸调整**

$\left(\LARGE{AB}\right)$ `\left(\LARGE{AB}\right)`

$( \big( \Big( \bigg( \Bigg($ `( \big( \Big( \bigg( \Bigg(`

||||||
|:--------|:------|:--------|:-------|:------|
|`\left`  |`\big` |`\bigl`  |`\bigm` |`\bigr`
|`\middle`|`\Big` |`\Bigl`  |`\Bigm` | `\Bigr`
|`\right` |`\bigg`|`\biggl` |`\biggm`|`\biggr`
|         |`\Bigg`|`\Biggl` |`\Biggm`|`\Biggr`


## 环境

|||||
|:---------------------|:---------------------|:---------------------|:--------
|$\begin{matrix} a & b \\ c & d \end{matrix}$ | `\begin{matrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{matrix}` |$\begin{array}{cc}a & b\\c & d\end{array}$ | `\begin{array}{cc}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{array}`
|$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$ |`\begin{pmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{pmatrix}` |$\begin{bmatrix} a & b \\ c & d \end{bmatrix}$ | `\begin{bmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{bmatrix}`
|$\begin{vmatrix} a & b \\ c & d \end{vmatrix}$ |`\begin{vmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{vmatrix}` |$\begin{Vmatrix} a & b \\ c & d \end{Vmatrix}$ |`\begin{Vmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{Vmatrix}`
|$\begin{Bmatrix} a & b \\ c & d \end{Bmatrix}$ |`\begin{Bmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{Bmatrix}`|$\def\arraystretch{1.5}\begin{array}{c:c:c} a & b & c \\ \hline d & e & f \\ \hdashline g & h & i \end{array}$|`\def\arraystretch{1.5}`<br>&nbsp;&nbsp;&nbsp;`\begin{array}{c:c:c}`<br>&nbsp;&nbsp;&nbsp;`a & b & c \\ \hline`<br>&nbsp;&nbsp;&nbsp;`d & e & f \\`<br>&nbsp;&nbsp;&nbsp;`\hdashline`<br>&nbsp;&nbsp;&nbsp;`g & h & i`<br>`\end{array}`
|$x = \begin{cases} a &\text{if } b \\ c &\text{if } d \end{cases}$ |`x = \begin{cases}`<br>&nbsp;&nbsp;&nbsp;`a &\text{if } b  \\`<br>&nbsp;&nbsp;&nbsp;`c &\text{if } d`<br>`\end{cases}`|$\begin{rcases} a &\text{if } b \\ c &\text{if } d \end{rcases}⇒…$ |`\begin{rcases}`<br>&nbsp;&nbsp;&nbsp;`a &\text{if } b  \\`<br>&nbsp;&nbsp;&nbsp;`c &\text{if } d`<br>`\end{rcases}⇒…`|
|$\begin{smallmatrix} a & b \\ c & d \end{smallmatrix}$ | `\begin{smallmatrix}`<br>&nbsp;&nbsp;&nbsp;`a & b \\`<br>&nbsp;&nbsp;&nbsp;`c & d`<br>`\end{smallmatrix}` |$$\sum_{\begin{subarray}{l}  i\in\Lambda\\  0<j<n\end{subarray}}$$ | `\sum_{`<br>`\begin{subarray}{l}`<br>&nbsp;&nbsp;&nbsp;`i\in\Lambda\\`<br>&nbsp;&nbsp;&nbsp;`0<j<n`<br>`\end{subarray}}`|

自动渲染（auto-render）扩展会渲染以下环境，即使它们没有被包在 `$$…$$` 之类的数学定界符内。这些环境仅支持显示（display）模式。


|||||
|:---------------------|:---------------------|:---------------------|:--------
|$$\begin{equation}\begin{split}a &=b+c\\&=e+f\end{split}\end{equation}$$ |`\begin{equation}`<br>`\begin{split}`&nbsp;&nbsp;&nbsp;`a &=b+c\\`<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`&=e+f`<br>`\end{split}`<br>`\end{equation}` |$$\begin{align} a&=b+c \\ d+e&=f \end{align}$$ |`\begin{align}`<br>&nbsp;&nbsp;&nbsp;`a&=b+c \\`<br>&nbsp;&nbsp;&nbsp;`d+e&=f`<br>`\end{align}` |
|$$\begin{gather} a=b \\ e=b+c \end{gather}$$ |`\begin{gather}`<br>&nbsp;&nbsp;&nbsp;`a=b \\ `<br>&nbsp;&nbsp;&nbsp;`e=b+c`<br>`\end{gather}`|$$\begin{alignat}{2}10&x+&3&y=2\\3&x+&13&y=4\end{alignat}$$ | `\begin{alignat}{2}`<br>&nbsp;&nbsp;&nbsp;`10&x+&3&y=2\\`<br>&nbsp;&nbsp;&nbsp;`3&x+&13&y=4`<br>`\end{alignat}`
|$$\begin{CD}A @>a>> B \\@VbVV @AAcA\\C @= D\end{CD}$$ | `\begin{CD}`<br>&nbsp;&nbsp;&nbsp;`A  @>a>>  B  \\`<br>`@VbVV    @AAcA \\`<br>&nbsp;&nbsp;&nbsp;`C  @=   D`<br>`\end{CD}`

#### 其他 KaTeX 环境

| 环境 | 与上面所示环境的区别 |
|:-----------------------------------------------|:------------------|
| `darray`、`dcases`、`drcases`                  | …… 应用 `displaystyle` |
| `matrix*`、`pmatrix*`、`bmatrix*`<br>`Bmatrix*`、`vmatrix*`、`Vmatrix*` | …… 接受一个可选参数来设置列<br>对齐方式，如 `\begin{matrix*}[r]` |
| `equation*`、`gather*`<br>`align*`、`alignat*` | …… 没有自动编号。另外，你也可以使用 `\nonumber` 或 `\notag` 来取消公式中某一行的编号。 |
| `gathered`、`aligned`、`alignedat`             | …… 不需要处于显示模式。<br> …… 没有自动编号。<br> …… 必须放在数学定界符内，才能被自动渲染<br>扩展渲染。 |


可接受的换行符包括：`\\`、`\cr`、`\\[distance]` 和 `\cr[distance]`。*distance*（距离）可以使用任意 [KaTeX 单位](#units) 来书写。

`{array}` 环境支持 `|` 和 `:` 两种竖直分隔线。

`{array}` 环境尚不支持 `\cline` 或 `\multicolumn`。

`\tag` 可以应用于顶层环境
（`align`、`align*`、`alignat`、`alignat*`、`gather`、`gather*`）中的单独一行。


## HTML

以下“原始 HTML”功能对于不可信的输入存在潜在危险，
因此默认处于禁用状态，尝试使用它们会以红色显示命令名
（可通过 `errorColor` [选项](options.md) 配置）。如果你完全信任你的 LaTeX
输入，可以传入 `trust: true` 选项；你也可以通过 `trust` [选项](options.md)
只启用部分命令，或只对部分 URL 启用。

|||
|:----------------|:-------------------|
| $\href{https://katex.org/}{\KaTeX}$ | `\href{https://katex.org/}{\KaTeX}` |
| $\url{https://katex.org/}$ | `\url{https://katex.org/}` |
| $\includegraphics[height=0.8em, totalheight=0.9em, width=0.9em, alt=KA logo]{https://katex.org/img/khan-academy.png}$ | `\includegraphics[height=0.8em, totalheight=0.9em, width=0.9em, alt=KA logo]{https://katex.org/img/khan-academy.png}` |
| $\htmlId{bar}{x}$ <code>…&lt;span id="bar" class="enclosing"&gt;…x…&lt;/span&gt;…</code> | `\htmlId{bar}{x}` |
| $\htmlClass{foo}{x}$ <code>…&lt;span class="enclosing foo"&gt;…x…&lt;/span&gt;…</code> | `\htmlClass{foo}{x}` |
| $\htmlStyle{color: red;}{x}$ <code>…&lt;span style="color: red;" class="enclosing"&gt;…x…&lt;/span&gt;…</code> | `\htmlStyle{color: red;}{x}` |
| $\htmlData{foo=a, bar=b}{x}$ <code>…&lt;span data-foo="a" data-bar="b" class="enclosing"&gt;…x…&lt;/span&gt;…</code> | `\htmlData{foo=a, bar=b}{x}` |

`\includegraphics` 的第一个参数支持 `height`、`width`、`totalheight` 和 `alt`。其中 `height` 是必需的。

HTML 扩展（以 `\html` 开头的）命令是非标准的，因此需要将 `htmlExtension` 的 `strict` 选项放宽。

## 字母与 Unicode

**希腊字母**

直接输入：$Α Β Γ Δ Ε Ζ Η Θ Ι \allowbreak Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω$
$\allowbreak α β γ δ ϵ ζ η θ ι κ λ μ ν ξ o π \allowbreak ρ σ τ υ ϕ χ ψ ω ε ϑ ϖ ϱ ς φ ϝ$

|||||
|---------------|-------------|-------------|---------------|
| $\Alpha$ `\Alpha` | $\Beta$ `\Beta` | $\Gamma$ `\Gamma`| $\Delta$ `\Delta`
| $\Epsilon$ `\Epsilon` | $\Zeta$ `\Zeta` | $\Eta$ `\Eta` | $\Theta$ `\Theta`
| $\Iota$ `\Iota` | $\Kappa$ `\Kappa` | $\Lambda$ `\Lambda` | $\Mu$ `\Mu`
| $\Nu$ `\Nu` | $\Xi$ `\Xi` | $\Omicron$ `\Omicron` | $\Pi$ `\Pi`
| $\Rho$ `\Rho` | $\Sigma$ `\Sigma` | $\Tau$ `\Tau` | $\Upsilon$ `\Upsilon`
| $\Phi$ `\Phi` | $\Chi$ `\Chi` | $\Psi$ `\Psi` | $\Omega$ `\Omega`
| $\varGamma$ `\varGamma`| $\varDelta$ `\varDelta` | $\varTheta$ `\varTheta` | $\varLambda$ `\varLambda`  |
| $\varXi$ `\varXi`| $\varPi$ `\varPi` | $\varSigma$ `\varSigma` | $\varUpsilon$ `\varUpsilon` |
| $\varPhi$ `\varPhi`  | $\varPsi$ `\varPsi`| $\varOmega$ `\varOmega` ||
| $\alpha$ `\alpha`| $\beta$ `\beta`  | $\gamma$ `\gamma` | $\delta$ `\delta`|
| $\epsilon$ `\epsilon` | $\zeta$ `\zeta`  | $\eta$ `\eta`| $\theta$ `\theta`|
| $\iota$ `\iota` | $\kappa$ `\kappa` | $\lambda$ `\lambda`| $\mu$ `\mu`|
| $\nu$ `\nu`| $\xi$ `\xi` | $\omicron$ `\omicron`  | $\pi$ `\pi`|
| $\rho$ `\rho`  | $\sigma$ `\sigma` | $\tau$ `\tau`| $\upsilon$ `\upsilon` |
| $\phi$ `\phi`  | $\chi$ `\chi`| $\psi$ `\psi`| $\omega$ `\omega`|
| $\varepsilon$ `\varepsilon` | $\varkappa$ `\varkappa` | $\vartheta$ `\vartheta` | $\thetasym$ `\thetasym`
| $\varpi$ `\varpi`| $\varrho$ `\varrho`  | $\varsigma$ `\varsigma` | $\varphi$ `\varphi`
| $\digamma $ `\digamma`

**其他字母**

||||||
|:----------|:----------|:----------|:----------|:----------|
|$\imath$ `\imath`|$\nabla$ `\nabla`|$\Im$ `\Im`|$\Reals$ `\Reals`|$\text{\OE}$ `\text{\OE}`
|$\jmath$ `\jmath`|$\partial$ `\partial`|$\image$ `\image`|$\wp$ `\wp`|$\text{\o}$ `\text{\o}`
|$\aleph$ `\aleph`|$\Game$ `\Game`|$\Bbbk$ `\Bbbk`|$\weierp$ `\weierp`|$\text{\O}$ `\text{\O}`
|$\alef$ `\alef`|$\Finv$ `\Finv`|$\N$ `\N`|$\Z$ `\Z`|$\text{\ss}$ `\text{\ss}`
|$\alefsym$ `\alefsym`|$\cnums$ `\cnums`|$\natnums$ `\natnums`|$\text{\aa}$ `\text{\aa}`|$\text{\i}$ `\text{\i}`
|$\beth$ `\beth`|$\Complex$ `\Complex`|$\R$ `\R`|$\text{\AA}$ `\text{\AA}`|$\text{\j}$ `\text{\j}`
|$\gimel$ `\gimel`|$\ell$ `\ell`|$\Re$ `\Re`|$\text{\ae}$ `\text{\ae}`
|$\daleth$ `\daleth`|$\hbar$ `\hbar`|$\real$ `\real`|$\text{\AE}$ `\text{\AE}`
|$\eth$ `\eth`|$\hslash$ `\hslash`|$\reals$ `\reals`|$\text{\oe}$ `\text{\oe}`

直接输入：$∂ ∇ ℑ Ⅎ ℵ ℶ ℷ ℸ ⅁ ℏ ð − ∗$
ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝÞßàáâãäåçèéêëìíîïðñòóôöùúûüýþÿ
₊₋₌₍₎₀₁₂₃₄₅₆₇₈₉ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓᵦᵧᵨᵩᵪ⁺⁻⁼⁽⁾⁰¹²³⁴⁵⁶⁷⁸⁹ᵃᵇᶜᵈᵉᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘʷˣʸᶻᵛᵝᵞᵟᵠᵡ

数学模式下的 Unicode 上下标字符，其渲染效果与你写成普通字符的下标或上标完全相同。例如，`A²⁺³` 的渲染效果与 `A^{2+3}` 一致。

**波斯语/阿拉伯语数字**
如需波斯语/阿拉伯语数字的支持，可以尝试第三方插件 [persian-katex-plugin](https://github.com/HosseinAgha/persian-katex-plugin)。


**Unicode 数学字母数字符号**

| 项目        |  范围              |  项目             |  范围  |
|-------------|---------------------|-------------------|---------------|
| 粗体        | $\text{𝐀-𝐙 𝐚-𝐳 𝟎-𝟗}$  | 双线体     | $\text{𝔸-}ℤ\ 𝕜$
| 斜体      | $\text{𝐴-𝑍 𝑎-𝑧}$      | 无衬线体        | $\text{𝖠-𝖹 𝖺-𝗓 𝟢-𝟫}$
| 粗斜体 | $\text{𝑨-𝒁 𝒂-𝒛}$      | 无衬线粗体   | $\text{𝗔-𝗭 𝗮-𝘇 𝟬-𝟵}$
| 手写体      | $\text{𝒜-𝒵}$         | 无衬线斜体 | $\text{𝘈-𝘡 𝘢-𝘻}$
| 德文尖角体     | $\text{$𝔄$-$ℨ$}\text{ $𝔞$-$𝔷$}$| 等宽体        | $\text{𝙰-𝚉 𝚊-𝚣 𝟶-𝟿}$
| 德文尖角粗体 | $\text{𝕬-𝖅 𝖆-𝖟}$ | |


**Unicode**

上面列出的字母在任何 KaTeX 渲染模式下都能正常显示。

此外，亚美尼亚文、婆罗米系文字、格鲁吉亚文、中文、日文和韩文的字形在文本模式下始终可用。不过，这些字形会使用系统字体（而非 KaTeX 自带字体）渲染，因此排版风格可能不一致。
你可以为 CSS 类 `.latin_fallback`、`.cyrillic_fallback`、`.brahmic_fallback`、`.georgian_fallback`、`.cjk_fallback` 和 `.hangul_fallback` 提供规则，为这些语言指定后备字体。
使用这些字形可能造成轻微的垂直对齐问题：KaTeX 对列出的符号以及大多数拉丁、希腊和西里尔字母有详细的度量信息，但其他可用字形会被当作与当前 KaTeX 字体中字母 M 等高来处理。

如果 KaTeX 渲染模式设置为 `strict: false` 或 `strict: "warn"`（默认值），那么 KaTeX 会在文本模式和数学模式下接受所有 Unicode 字母。
所有无法识别的字符都会被当作出现在文本模式中处理，同样存在使用系统字体以及垂直对齐可能不正确的问题。

对于波斯语复合字符，一个用户提供的[插件](https://github.com/HosseinAgha/persian-katex-plugin)正在开发中。

任何字符都可以通过 `\char` 函数加上十六进制的 Unicode 编码来书写。例如 `\char"263a` 会渲染为 $\char"263a$。

## 布局

### 标注

|                                                                         |                                                                           |
|:------------------------------------------------------------------------|:--------------------------------------------------------------------------|
| $\cancel{5}$ `\cancel{5}`                                               | $\overbrace{a+b+c}^{\text{note}}$ `\overbrace{a+b+c}^{\text{note}}`       |
| $\bcancel{5}$ `\bcancel{5}`                                             | $\underbrace{a+b+c}_{\text{note}}$ `\underbrace{a+b+c}_{\text{note}}`     |
| $\xcancel{ABC}$ `\xcancel{ABC}`                                         | $\not =$ `\not =`                                                         |
| $\text{\sout{abc}}$ `\text{\sout{abc}}`                                 | $\boxed{\pi=\frac c d}$ `\boxed{\pi=\frac c d}`                           |
| $a_{\angl n}$ `$a_{\angl n}`                                            | $a_\angln$ `a_\angln`                                                     |
| $\overbracket{a+b+c}^{\text{note}}$ `\overbracket{a+b+c}^{\text{note}}` | $\underbracket{a+b+c}_{\text{note}}$ `\underbracket{a+b+c}_{\text{note}}` |
| $\phase{-78^\circ}$`\phase{-78^\circ}`                                  |                                                                           |

`\tag{hi} x+y^{2x}`
$$\tag{hi} x+y^{2x}$$

`\tag*{hi} x+y^{2x}`
$$\tag*{hi} x+y^{2x}$$

### 换行

KaTeX 0.10.0+ 会在行内数学中，在 “=” 或 “+” 之类的关系符或二元运算符之后自动插入换行。可以通过 `\nobreak` 或将数学内容放入一对花括号中（如 `{F=ma}`）来抑制这种自动换行。`\allowbreak` 则允许在关系符或运算符之外的位置自动换行。

硬换行是 `\\` 和 `\newline`。

在显示数学中，KaTeX 不会插入自动换行。当渲染选项为 `strict: true` 时，它会忽略显示数学中的硬换行。

### 垂直布局

||||
|:--------------|:----------------------------------------|:-----
|$x_n$ `x_n` |$\stackrel{!}{=}$ `\stackrel{!}{=}`| $a \atop b$ `a \atop b`
|$e^x$ `e^x` |$\overset{!}{=}$ `\overset{!}{=}`  | $a\raisebox{0.25em}{$b$}c$ `a\raisebox{0.25em}{$b$}c`
|$_u^o $ `_u^o `| $\underset{!}{=}$ `\underset{!}{=}` | $a+\left(\vcenter{\frac{\frac a b}c}\right)$ `a+\left(\vcenter{\hbox{$\frac{\frac a b}c$}}\right)`
||| $$\sum_{\substack{0<i<m\\0<j<n}}$$ `\sum_{\substack{0<i<m\\0<j<n}}`

`\raisebox` 和 `\hbox` 会将其参数置于文本模式。若要抬升数学内容，需如上文所示在参数内嵌套 `$…$` 定界符。

如果 `strict` 渲染选项为 *false*，`\vcenter` 可以不用 `\hbox` 书写。此时可省略嵌套的 `$…$` 定界符。

### 重叠与间距

|||
|:-------|:-------|
|${=}\mathllap{/\,}$ `{=}\mathllap{/\,}` | $\left(x^{\smash{2}}\right)$ `\left(x^{\smash{2}}\right)`
|$\mathrlap{\,/}{=}$ `\mathrlap{\,/}{=}` | $\sqrt{\smash[b]{y}}$ `\sqrt{\smash[b]{y}} `

$\displaystyle\sum_{\mathclap{1\le i\le j\le n}} x_{ij}$ `\sum_{\mathclap{1\le i\le j\le n}} x_{ij}`

KaTeX 还支持 `\llap`、`\rlap` 和 `\clap`，但它们只接受文本参数，不接受数学参数。

**间距**

| 函数        | 效果           | 函数             | 效果|
|:----------------|:-------------------|:---------------------|:--------------------------------------|
| `\,`            | ³∕₁₈ em 间距      | `\kern{distance}`    | 间距，宽度 = *distance*
| `\thinspace`    | ³∕₁₈ em 间距      | `\mkern{distance}`   | 间距，宽度 = *distance*
| `\>`            | ⁴∕₁₈ em 间距      | `\mskip{distance}`   | 间距，宽度 = *distance*
| `\:`            | ⁴∕₁₈ em 间距      | `\hskip{distance}`   | 间距，宽度 = *distance*
| `\medspace`     | ⁴∕₁₈ em 间距      | `\hspace{distance}`  | 间距，宽度 = *distance*
| `\;`            | ⁵∕₁₈ em 间距      | `\hspace*{distance}` | 间距，宽度 = *distance*
| `\thickspace`   | ⁵∕₁₈ em 间距      | `\phantom{content}`  | 与 content 宽高相同的空白
| `\enspace`      | ½ em 间距         | `\hphantom{content}` | 与 content 同宽的空白
| `\quad`         | 1 em 间距         | `\vphantom{content}` | 与 content 同高的撑杆（strut）
| `\qquad`        | 2 em 间距         | `\!`                 | – ³∕₁₈ em 间距
| `~`             | 不换行空格 | `\negthinspace`      | – ³∕₁₈ em 间距
| `\<空格>`      | 空格              | `\negmedspace`       | – ⁴∕₁₈ em 间距
| `\nobreakspace` | 不换行空格 | `\negthickspace`     | – ⁵∕₁₈ em 间距
| `\space`        | 空格              | `\mathstrut`         | `\vphantom{(}`

**说明：**

`distance` 接受任意 [KaTeX 单位](#单位)。

`\kern`、`\mkern`、`\mskip` 和 `\hspace` 接受不带花括号的距离值，如 `\kern1em`。

`\mkern` 和 `\mskip` 在文本模式下无效，且对于除 `mu` 以外的任何单位都会在控制台输出警告。

## 逻辑与集合论

$\gdef\VERT{|}$

|||||
|:--------------------|:--------------------------|:----------------------------|:-----
|$\forall$ `\forall`  |$\complement$ `\complement`|$\therefore$ `\therefore`    |$\emptyset$ `\emptyset`
|$\exists$ `\exists`  |$\subset$ `\subset`  |$\because$ `\because`              |$\empty$ `\empty`
|$\exist$ `\exist`    |$\supset$ `\supset`  |$\mapsto$ `\mapsto`                |$\varnothing$ `\varnothing`
|$\nexists$ `\nexists`|$\mid$ `\mid`        |$\to$ `\to`                        |$\implies$ `\implies`
|$\in$ `\in`          |$\land$ `\land`      |$\gets$ `\gets`                    |$\impliedby$ `\impliedby`
|$\isin$ `\isin`      |$\lor$ `\lor`        |$\leftrightarrow$ `\leftrightarrow`|$\iff$ `\iff`
|$\notin$ `\notin`    |$\ni$ `\ni`          |$\notni$ `\notni`                  |$\neg$ `\neg` 或 `\lnot`
|   | $\Set{ x \VERT x<\frac 1 2 }$<br><code>\Set{ x &#124; x<\frac 1 2 }</code>  | $\set{x\VERT x<5}$<br><code>\set{x&#124;x<5}</code> ||

直接输入：$∀ ∴ ∁ ∵ ∃ ∣ ∈ ∉ ∋ ⊂ ⊃ ∧ ∨ ↦ → ← ↔ ¬$ ℂ ℍ ℕ ℙ ℚ ℝ

## 宏

|||
|:-------------------------------------|:------
|$\def\foo{x^2} \foo + \foo$           | `\def\foo{x^2} \foo + \foo`
|$\gdef\foo#1{#1^2} \foo{y} + \foo{y}$ | `\gdef\foo#1{#1^2} \foo{y} + \foo{y}`
|                                      | `\edef\macroname#1#2…{definition to be expanded}`
|                                      | `\xdef\macroname#1#2…{definition to be expanded}`
|                                      | `\let\foo=\bar`
|                                      | `\futurelet\foo\bar x`
|                                      | `\global\def\macroname#1#2…{definition}`
|                                      | `\newcommand\macroname[numargs]{definition}`
|                                      | `\renewcommand\macroname[numargs]{definition}`
|                                      | `\providecommand\macroname[numargs]{definition}`

宏也可以在 KaTeX 的[渲染选项](options.md)中定义。

宏最多可接受九个参数：#1、#2 等。

由 `\gdef`、`\xdef`、`\global\def`、`\global\edef`、`\global\let` 和 `\global\futurelet` 定义的宏会在多个数学表达式之间持续生效。（例外情况：宏的持久化可能被禁用——这有正当的安全考虑。）

KaTeX 没有 `\par`，因此所有宏默认都是长宏（long），`\long` 会被忽略。

可用的函数包括：

`\char` `\mathchoice` `\TextOrMath` `\@ifstar` `\@ifnextchar` `\@firstoftwo` `\@secondoftwo` `\relax` `\expandafter` `\noexpand`

@ 是命令中的合法字符，就如同 `\makeatletter` 已生效一样。

## 运算符

### 大型运算符

|||||
|------------------|-------------------------|--------------------------|--------------|
| $\sum$ `\sum`    | $\prod$ `\prod`         | $\bigotimes$ `\bigotimes`| $\bigvee$ `\bigvee`
| $\int$ `\int`    | $\coprod$ `\coprod`     | $\bigoplus$ `\bigoplus`  | $\bigwedge$ `\bigwedge`
| $\iint$ `\iint`  | $\intop$ `\intop`       | $\bigodot$ `\bigodot`    | $\bigcap$ `\bigcap`
| $\iiint$ `\iiint`| $\smallint$ `\smallint` | $\biguplus$ `\biguplus`  | $\bigcup$ `\bigcup`
| $\oint$ `\oint`  | $\oiint$ `\oiint`       | $\oiiint$ `\oiiint`      | $\bigsqcup$ `\bigsqcup`

直接输入：$∫ ∬ ∭ ∮ ∏ ∐ ∑ ⋀ ⋁ ⋂ ⋃ ⨀ ⨁ ⨂ ⨄ ⨆$ ∯ ∰

### 二元运算符

|||||
|-------------|-------------------|-------------------|--------------------|
| $+$ `+`| $\cdot$ `\cdot`  | $\gtrdot$ `\gtrdot`| $x \pmod a$ `x \pmod a`|
| $-$ `-`| $\cdotp$ `\cdotp` | $\intercal$ `\intercal` | $x \pod a$ `x \pod a` |
| $/$ `/`| $\centerdot$ `\centerdot`| $\land$ `\land`  | $\rhd$ `\rhd` |
| $*$ `*`| $\circ$ `\circ`  | $\leftthreetimes$ `\leftthreetimes` | $\rightthreetimes$ `\rightthreetimes` |
| $\amalg$ `\amalg` | $\circledast$ `\circledast`  | $\ldotp$ `\ldotp` | $\rtimes$ `\rtimes` |
| $\And$ `\And`| $\circledcirc$ `\circledcirc` | $\lor$ `\lor`| $\setminus$ `\setminus`  |
| $\ast$ `\ast`| $\circleddash$ `\circleddash` | $\lessdot$ `\lessdot`  | $\smallsetminus$ `\smallsetminus`|
| $\barwedge$ `\barwedge` | $\Cup$ `\Cup`| $\lhd$ `\lhd`| $\sqcap$ `\sqcap`  |
| $\bigcirc$ `\bigcirc`  | $\cup$ `\cup`| $\ltimes$ `\ltimes`| $\sqcup$ `\sqcup`  |
| $\bmod$ `\bmod`  | $\curlyvee$ `\curlyvee` | $x \mod a$ `x\mod a`| $\times$ `\times`  |
| $\boxdot$ `\boxdot`| $\curlywedge$ `\curlywedge`  | $\mp$ `\mp` | $\unlhd$ `\unlhd`  |
| $\boxminus$ `\boxminus` | $\div$ `\div`| $\odot$ `\odot`  | $\unrhd$ `\unrhd`  |
| $\boxplus$ `\boxplus`  | $\divideontimes$ `\divideontimes`  | $\ominus$ `\ominus`| $\uplus$ `\uplus`  |
| $\boxtimes$ `\boxtimes` | $\dotplus$ `\dotplus`  | $\oplus$ `\oplus` | $\vee$ `\vee` |
| $\bullet$ `\bullet`| $\doublebarwedge$ `\doublebarwedge` | $\otimes$ `\otimes`| $\veebar$ `\veebar` |
| $\Cap$ `\Cap`| $\doublecap$ `\doublecap`| $\oslash$ `\oslash`| $\wedge$ `\wedge`  |
| $\cap$ `\cap`| $\doublecup$ `\doublecup`| $\pm$ `\pm` 或 `\plusmn` | $\wr$ `\wr`  |

直接输入：$+ - / * ⋅ ∘ ∙ ± × ÷ ∓ ∔ ∧ ∨ ∩ ∪ ≀ ⊎ ⊓ ⊔ ⊕ ⊖ ⊗ ⊘ ⊙ ⊚ ⊛ ⊝ ◯ ∖ {}$

### 分数与二项式系数

||||
|:--------------------------|:----------------------------|:-----
|$\frac{a}{b}$ `\frac{a}{b}`|$\tfrac{a}{b}$ `\tfrac{a}{b}`|$\genfrac ( ] {2pt}{1}a{a+1}$ `\genfrac ( ] {2pt}{1}a{a+1}`
|${a \over b}$ `{a \over b}`|$\dfrac{a}{b}$ `\dfrac{a}{b}`|${a \above{2pt} b+1}$ `{a \above{2pt} b+1}`
|$a/b$ `a/b`                |  |$\cfrac{a}{1 + \cfrac{1}{b}}$ `\cfrac{a}{1 + \cfrac{1}{b}}`

||||
|:------------------------------|:------------------------------|:--------
|$\binom{n}{k}$ `\binom{n}{k}`  |$\dbinom{n}{k}$ `\dbinom{n}{k}`|${n\brace k}$ `{n\brace k}`
|${n \choose k}$ `{n \choose k}`|$\tbinom{n}{k}$ `\tbinom{n}{k}`|${n\brack k}$ `{n\brack k}`

### 数学函数（运算符名）

|||||
|:--------------------|:--------------------|:----------------|:--------------|
| $\arcsin$ `\arcsin` | $\cosec$ `\cosec`   | $\deg$ `\deg`   | $\sec$ `\sec` |
| $\arccos$ `\arccos` | $\cosh$ `\cosh`     | $\dim$ `\dim`   | $\sin$ `\sin` |
| $\arctan$ `\arctan` | $\cot$ `\cot`       | $\exp$ `\exp`   | $\sinh$ `\sinh` |
| $\arctg$ `\arctg`   | $\cotg$ `\cotg`     | $\hom$ `\hom`   | $\sh$ `\sh` |
| $\arcctg$ `\arcctg` | $\coth$ `\coth`     | $\ker$ `\ker`   | $\tan$ `\tan` |
| $\arg$ `\arg`       | $\csc$ `\csc`       | $\lg$ `\lg`     | $\tanh$ `\tanh` |
| $\ch$ `\ch`         | $\ctg$ `\ctg`       | $\ln$ `\ln`     | $\tg$ `\tg` |
| $\cos$ `\cos`       | $\cth$ `\cth`       | $\log$ `\log`   | $\th$ `\th` |
| $\operatorname{f}$ `\operatorname{f}`     | |||
| $\argmax$ `\argmax` | $\injlim$ `\injlim` | $\min$ `\min`   | $\varinjlim$ `\varinjlim` |
| $\argmin$ `\argmin` | $\lim$ `\lim`       | $\plim$ `\plim` | $\varliminf$ `\varliminf` |
| $\det$ `\det`       | $\liminf$ `\liminf` | $\Pr$ `\Pr`     | $\varlimsup$ `\varlimsup` |
| $\gcd$ `\gcd`       | $\limsup$ `\limsup` | $\projlim$ `\projlim` | $\varprojlim$ `\varprojlim` |
| $\inf$ `\inf`       | $\max$ `\max`       | $\sup$ `\sup`   ||
| $\operatorname*{f}$ `\operatorname*{f}` | $\operatornamewithlimits{f}$ `\operatornamewithlimits{f}` |||

本表中最后六行的函数可以搭配 `\limits` 使用。

### \sqrt

$\sqrt{x}$ `\sqrt{x}`

$\sqrt[3]{x}$ `\sqrt[3]{x}`

## 关系符号

$\stackrel{!}{=}$ `\stackrel{!}{=}`

|||||
|:--------|:------------------------|:----------------------------|:------------------|
| $=$ `=` | $\doteqdot$ `\doteqdot` | $\lessapprox$ `\lessapprox` | $\smile$ `\smile` |
| $<$ `<` | $\eqcirc$ `\eqcirc` | $\lesseqgtr$ `\lesseqgtr` | $\sqsubset$ `\sqsubset` |
| $>$ `>` | $\eqcolon$ `\eqcolon` 或<br>    `\minuscolon` | $\lesseqqgtr$ `\lesseqqgtr` | $\sqsubseteq$ `\sqsubseteq` |
| $:$ `:` | $\Eqcolon$ `\Eqcolon` 或<br>    `\minuscoloncolon` | $\lessgtr$ `\lessgtr` | $\sqsupset$ `\sqsupset` |
| $\approx$ `\approx` | $\eqqcolon$ `\eqqcolon` 或<br>    `\equalscolon` | $\lesssim$ `\lesssim` | $\sqsupseteq$ `\sqsupseteq` |
| $\approxcolon$ `\approxcolon` | $\Eqqcolon$ `\Eqqcolon` 或<br>    `\equalscoloncolon` | $\ll$ `\ll` | $\Subset$ `\Subset` |
| $\approxcoloncolon$ `\approxcoloncolon` | $\eqsim$ `\eqsim` | $\lll$ `\lll` | $\subset$ `\subset` 或 `\sub` |
| $\approxeq$ `\approxeq` | $\eqslantgtr$ `\eqslantgtr` | $\llless$ `\llless` | $\subseteq$ `\subseteq` 或 `\sube` |
| $\asymp$ `\asymp` | $\eqslantless$ `\eqslantless` | $\lt$ `\lt` | $\subseteqq$ `\subseteqq` |
| $\backepsilon$ `\backepsilon` | $\equiv$ `\equiv` | $\mid$ `\mid` | $\succ$ `\succ` |
| $\backsim$ `\backsim` | $\fallingdotseq$ `\fallingdotseq` | $\models$ `\models` | $\succapprox$ `\succapprox` |
| $\backsimeq$ `\backsimeq` | $\frown$ `\frown` | $\multimap$ `\multimap` | $\succcurlyeq$ `\succcurlyeq` |
| $\between$ `\between` | $\ge$ `\ge` | $\origof$ `\origof` | $\succeq$ `\succeq` |
| $\bowtie$ `\bowtie` | $\geq$ `\geq` | $\owns$ `\owns` | $\succsim$ `\succsim` |
| $\bumpeq$ `\bumpeq` | $\geqq$ `\geqq` | $\parallel$ `\parallel` | $\Supset$ `\Supset` |
| $\Bumpeq$ `\Bumpeq` | $\geqslant$ `\geqslant` | $\perp$ `\perp` | $\supset$ `\supset` |
| $\circeq$ `\circeq` | $\gg$ `\gg` | $\pitchfork$ `\pitchfork` | $\supseteq$ `\supseteq` 或 `\supe` |
| $\colonapprox$ `\colonapprox` | $\ggg$ `\ggg` | $\prec$ `\prec` | $\supseteqq$ `\supseteqq` |
| $\Colonapprox$ `\Colonapprox` 或<br>    `\coloncolonapprox` | $\gggtr$ `\gggtr` | $\precapprox$ `\precapprox` | $\thickapprox$ `\thickapprox` |
| $\coloneq$ `\coloneq` 或<br>    `\colonminus` | $\gt$ `\gt` | $\preccurlyeq$ `\preccurlyeq` | $\thicksim$ `\thicksim` |
| $\Coloneq$ `\Coloneq` 或<br>    `\coloncolonminus` | $\gtrapprox$ `\gtrapprox` | $\preceq$ `\preceq` | $\trianglelefteq$ `\trianglelefteq` |
| $\coloneqq$ `\coloneqq` 或<br>   `\colonequals` | $\gtreqless$ `\gtreqless` | $\precsim$ `\precsim` | $\triangleq$ `\triangleq` |
| $\Coloneqq$ `\Coloneqq` 或<br>    `\coloncolonequals` | $\gtreqqless$ `\gtreqqless` | $\propto$ `\propto` | $\trianglerighteq$ `\trianglerighteq` |
| $\colonsim$ `\colonsim` | $\gtrless$ `\gtrless` | $\risingdotseq$ `\risingdotseq` | $\varpropto$ `\varpropto` |
| $\Colonsim$ `\Colonsim` 或<br>    `\coloncolonsim` | $\gtrsim$ `\gtrsim` | $\shortmid$ `\shortmid` | $\vartriangle$ `\vartriangle` |
| $\cong$ `\cong` | $\imageof$ `\imageof` | $\shortparallel$ `\shortparallel` | $\vartriangleleft$ `\vartriangleleft` |
| $\curlyeqprec$ `\curlyeqprec` | $\in$ `\in` 或 `\isin` | $\sim$ `\sim` | $\vartriangleright$ `\vartriangleright` |
| $\curlyeqsucc$ `\curlyeqsucc` | $\Join$ `\Join` | $\simcolon$ `\simcolon` | $\vcentcolon$ `\vcentcolon` 或<br>   `\ratio` |
| $\dashv$ `\dashv` | $\le$ `\le` | $\simcoloncolon$ `\simcoloncolon` | $\vdash$ `\vdash` |
| $\dblcolon$ `\dblcolon` 或<br>   `\coloncolon` | $\leq$ `\leq` | $\simeq$ `\simeq` | $\vDash$ `\vDash` |
| $\doteq$ `\doteq` | $\leqq$ `\leqq` | $\smallfrown$ `\smallfrown` | $\Vdash$ `\Vdash` |
| $\Doteq$ `\Doteq` | $\leqslant$ `\leqslant` | $\smallsmile$ `\smallsmile` | $\Vvdash$ `\Vvdash` |

直接输入：$= < > : ∈ ∋ ∝ ∼ ∽ ≂ ≃ ≅ ≈ ≊ ≍ ≎ ≏ ≐ ≑ ≒ ≓ ≖ ≗ ≜ ≡ ≤ ≥ ≦ ≧ ≫ ≬ ≳ ≷ ≺ ≻ ≼ ≽ ≾ ≿ ⊂ ⊃ ⊆ ⊇ ⊏ ⊐ ⊑ ⊒ ⊢ ⊣ ⊩ ⊪ ⊸ ⋈ ⋍ ⋐ ⋑ ⋔ ⋙ ⋛ ⋞ ⋟ ⌢ ⌣ ⩾ ⪆ ⪌ ⪕ ⪖ ⪯ ⪰ ⪷ ⪸ ⫅ ⫆ ≲ ⩽ ⪅ ≶ ⋚ ⪋ ⟂ ⊨ ⊶ ⊷$ `≔ ≕ ⩴`

### 否定关系符号

$\not =$ `\not =`

|||||
|--------------|-------------------|---------------------|------------------|
| $\gnapprox$ `\gnapprox`  | $\ngeqslant$ `\ngeqslant`| $\nsubseteq$ `\nsubseteq`  | $\precneqq$ `\precneqq`|
| $\gneq$ `\gneq`| $\ngtr$ `\ngtr`  | $\nsubseteqq$ `\nsubseteqq` | $\precnsim$ `\precnsim`|
| $\gneqq$ `\gneqq`  | $\nleq$ `\nleq`  | $\nsucc$ `\nsucc`| $\subsetneq$ `\subsetneq`  |
| $\gnsim$ `\gnsim`  | $\nleqq$ `\nleqq` | $\nsucceq$ `\nsucceq` | $\subsetneqq$ `\subsetneqq` |
| $\gvertneqq$ `\gvertneqq` | $\nleqslant$ `\nleqslant`| $\nsupseteq$ `\nsupseteq`  | $\succnapprox$ `\succnapprox`|
| $\lnapprox$ `\lnapprox`  | $\nless$ `\nless` | $\nsupseteqq$ `\nsupseteqq` | $\succneqq$ `\succneqq`|
| $\lneq$ `\lneq`| $\nmid$ `\nmid`  | $\ntriangleleft$ `\ntriangleleft` | $\succnsim$ `\succnsim`|
| $\lneqq$ `\lneqq`  | $\notin$ `\notin` | $\ntrianglelefteq$ `\ntrianglelefteq`  | $\supsetneq$ `\supsetneq`  |
| $\lnsim$ `\lnsim`  | $\notni$ `\notni` | $\ntriangleright$ `\ntriangleright`| $\supsetneqq$ `\supsetneqq` |
| $\lvertneqq$ `\lvertneqq` | $\nparallel$ `\nparallel`| $\ntrianglerighteq$ `\ntrianglerighteq` | $\varsubsetneq$ `\varsubsetneq`  |
| $\ncong$ `\ncong`  | $\nprec$ `\nprec` | $\nvdash$ `\nvdash`  | $\varsubsetneqq$ `\varsubsetneqq` |
| $\ne$ `\ne`  | $\npreceq$ `\npreceq`  | $\nvDash$ `\nvDash`  | $\varsupsetneq$ `\varsupsetneq`  |
| $\neq$ `\neq` | $\nshortmid$ `\nshortmid`| $\nVDash$ `\nVDash`  | $\varsupsetneqq$ `\varsupsetneqq` |
| $\ngeq$ `\ngeq`| $\nshortparallel$ `\nshortparallel` | $\nVdash$ `\nVdash`  |
| $\ngeqq$ `\ngeqq`  | $\nsim$ `\nsim`  | $\precnapprox$ `\precnapprox`|

直接输入：$∉ ∌ ∤ ∦ ≁ ≆ ≠ ≨ ≩ ≮ ≯ ≰ ≱ ⊀ ⊁ ⊈ ⊉ ⊊ ⊋ ⊬ ⊭ ⊮ ⊯ ⋠ ⋡ ⋦ ⋧ ⋨ ⋩ ⋬ ⋭ ⪇ ⪈ ⪉ ⪊ ⪵ ⪶ ⪹ ⪺ ⫋ ⫌$

### 箭头

||||
|:----------|:----------|:----------|
|$\circlearrowleft$ `\circlearrowleft`|$\leftharpoonup$ `\leftharpoonup`|$\rArr$ `\rArr`
|$\circlearrowright$ `\circlearrowright`|$\leftleftarrows$ `\leftleftarrows`|$\rarr$ `\rarr`
|$\curvearrowleft$ `\curvearrowleft`|$\leftrightarrow$ `\leftrightarrow`|$\restriction$ `\restriction`
|$\curvearrowright$ `\curvearrowright`|$\Leftrightarrow$ `\Leftrightarrow`|$\rightarrow$ `\rightarrow`
|$\Darr$ `\Darr`|$\leftrightarrows$ `\leftrightarrows`|$\Rightarrow$ `\Rightarrow`
|$\dArr$ `\dArr`|$\leftrightharpoons$ `\leftrightharpoons`|$\rightarrowtail$ `\rightarrowtail`
|$\darr$ `\darr`|$\leftrightsquigarrow$ `\leftrightsquigarrow`|$\rightharpoondown$ `\rightharpoondown`
|$\dashleftarrow$ `\dashleftarrow`|$\Lleftarrow$ `\Lleftarrow`|$\rightharpoonup$ `\rightharpoonup`
|$\dashrightarrow$ `\dashrightarrow`|$\longleftarrow$ `\longleftarrow`|$\rightleftarrows$ `\rightleftarrows`
|$\downarrow$ `\downarrow`|$\Longleftarrow$ `\Longleftarrow`|$\rightleftharpoons$ `\rightleftharpoons`
|$\Downarrow$ `\Downarrow`|$\longleftrightarrow$ `\longleftrightarrow`|$\rightrightarrows$ `\rightrightarrows`
|$\downdownarrows$ `\downdownarrows`|$\Longleftrightarrow$ `\Longleftrightarrow`|$\rightsquigarrow$ `\rightsquigarrow`
|$\downharpoonleft$ `\downharpoonleft`|$\longmapsto$ `\longmapsto`|$\Rrightarrow$ `\Rrightarrow`
|$\downharpoonright$ `\downharpoonright`|$\longrightarrow$ `\longrightarrow`|$\Rsh$ `\Rsh`
|$\gets$ `\gets`|$\Longrightarrow$ `\Longrightarrow`|$\searrow$ `\searrow`
|$\Harr$ `\Harr`|$\looparrowleft$ `\looparrowleft`|$\swarrow$ `\swarrow`
|$\hArr$ `\hArr`|$\looparrowright$ `\looparrowright`|$\to$ `\to`
|$\harr$ `\harr`|$\Lrarr$ `\Lrarr`|$\twoheadleftarrow$ `\twoheadleftarrow`
|$\hookleftarrow$ `\hookleftarrow`|$\lrArr$ `\lrArr`|$\twoheadrightarrow$ `\twoheadrightarrow`
|$\hookrightarrow$ `\hookrightarrow`|$\lrarr$ `\lrarr`|$\Uarr$ `\Uarr`
|$\iff$ `\iff`|$\Lsh$ `\Lsh`|$\uArr$ `\uArr`
|$\impliedby$ `\impliedby`|$\mapsto$ `\mapsto`|$\uarr$ `\uarr`
|$\implies$ `\implies`|$\nearrow$ `\nearrow`|$\uparrow$ `\uparrow`
|$\Larr$ `\Larr`|$\nleftarrow$ `\nleftarrow`|$\Uparrow$ `\Uparrow`
|$\lArr$ `\lArr`|$\nLeftarrow$ `\nLeftarrow`|$\updownarrow$ `\updownarrow`
|$\larr$ `\larr`|$\nleftrightarrow$ `\nleftrightarrow`|$\Updownarrow$ `\Updownarrow`
|$\leadsto$ `\leadsto`|$\nLeftrightarrow$ `\nLeftrightarrow`|$\upharpoonleft$ `\upharpoonleft`
|$\leftarrow$ `\leftarrow`|$\nrightarrow$ `\nrightarrow`|$\upharpoonright$ `\upharpoonright`
|$\Leftarrow$ `\Leftarrow`|$\nRightarrow$ `\nRightarrow`|$\upuparrows$ `\upuparrows`
|$\leftarrowtail$ `\leftarrowtail`|$\nwarrow$ `\nwarrow`
|$\leftharpoondown$ `\leftharpoondown`|$\Rarr$ `\Rarr`

直接输入：$← ↑ → ↓ ↔ ↕ ↖ ↗ ↘ ↙ ↚ ↛ ↞ ↠ ↢ ↣ ↦ ↩ ↪ ↫ ↬ ↭ ↮ ↰ ↱↶ ↷ ↺ ↻ ↼ ↽ ↾ ↾ ↿ ⇀ ⇁ ⇂ ⇃ ⇄ ⇆ ⇇ ⇈ ⇉ ⇊ ⇋ ⇌⇍ ⇎ ⇏ ⇐ ⇑ ⇒ ⇓ ⇔ ⇕ ⇚ ⇛ ⇝ ⇠ ⇢ ⟵ ⟶ ⟷ ⟸ ⟹ ⟺ ⟼$ ↽

**可延展箭头**

|||
|:----------------------------------------------------|:-----
|$\xleftarrow{abc}$ `\xleftarrow{abc}`                |$\xrightarrow[under]{over}$ `\xrightarrow[under]{over}`
|$\xLeftarrow{abc}$ `\xLeftarrow{abc}`                |$\xRightarrow{abc}$ `\xRightarrow{abc}`
|$\xleftrightarrow{abc}$ `\xleftrightarrow{abc}`      |$\xLeftrightarrow{abc}$ `\xLeftrightarrow{abc}`
|$\xhookleftarrow{abc}$ `\xhookleftarrow{abc}`        |$\xhookrightarrow{abc}$ `\xhookrightarrow{abc}`
|$\xtwoheadleftarrow{abc}$ `\xtwoheadleftarrow{abc}`  |$\xtwoheadrightarrow{abc}$ `\xtwoheadrightarrow{abc}`
|$\xleftharpoonup{abc}$ `\xleftharpoonup{abc}`        |$\xrightharpoonup{abc}$ `\xrightharpoonup{abc}`
|$\xleftharpoondown{abc}$ `\xleftharpoondown{abc}`    |$\xrightharpoondown{abc}$ `\xrightharpoondown{abc}`
|$\xleftrightharpoons{abc}$ `\xleftrightharpoons{abc}`|$\xrightleftharpoons{abc}$ `\xrightleftharpoons{abc}`
|$\xtofrom{abc}$ `\xtofrom{abc}`                      |$\xmapsto{abc}$ `\xmapsto{abc}`
|$\xlongequal{abc}$ `\xlongequal{abc}`

所有可延展箭头都可以像 `\xrightarrow[under]{over}` 一样<br>接受一个可选参数。

## 特殊记号

**Bra-ket 记号（狄拉克记号）**

||||
|:----------|:----------|:----------|
|$\bra{\phi}$ `\bra{\phi}` |$\ket{\psi}$ `\ket{\psi}` |$\braket{\phi\VERT\psi}$ <code>\braket{\phi&#124;\psi}</code> |
|$\Bra{\phi}$ `\Bra{\phi}` |$\Ket{\psi}$ `\Ket{\psi}` |$\Braket{ ϕ \VERT \frac{∂^2}{∂ t^2} \VERT ψ }$ <code>\Braket{ ϕ &#124; \frac{∂^2}{∂ t^2} &#124; ψ }</code>|

## 样式、颜色、大小与字体

**类别指定**

`\mathbin` `\mathclose` `\mathinner` `\mathop`<br>
`\mathopen` `\mathord` `\mathpunct` `\mathrel`

**颜色**

$\color{blue} F=ma$  `\color{blue} F=ma`

注意，`\color` 的作用类似一个开关。其他颜色函数则要求将内容作为函数参数传入：

$\textcolor{blue}{F=ma}$ `\textcolor{blue}{F=ma}`<br>
$\textcolor{#228B22}{F=ma}$ `\textcolor{#228B22}{F=ma}`<br>
$\colorbox{aqua}{$F=ma$}$ `\colorbox{aqua}{$F=ma$}`<br>
$\fcolorbox{red}{aqua}{$F=ma$}$ `\fcolorbox{red}{aqua}{$F=ma$}`

注意，与 LaTeX 一样，`\colorbox` 和 `\fcolorbox` 会将第三个参数渲染为文本，因此你可能需要像上面的例子那样用 `$` 切换回数学模式。

在颜色定义方面，KaTeX 的颜色函数接受标准的 HTML [预定义颜色名称](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#Color_keywords)，也接受 CSS 十六进制风格的 RGB 参数。六位十六进制数值前的 "#" 是可选的。

**字体**

||||
|:------------------------------------|:------------------------------------|:--------------------------------|
|$\mathrm{Ab0}$ `\mathrm{Ab0}`        |$\mathbf{Ab0}$ `\mathbf{Ab0}`        |$\mathsf{Ab0}$ `\mathsf{Ab0}`    |
|$\mathnormal{Ab0}$ `\mathnormal{Ab0}`|$\textbf{Ab0}$ `\textbf{Ab0}`        |$\textsf{Ab0}$ `\textsf{Ab0}`    |
|$\textrm{Ab0}$ `\textrm{Ab0}`        |$\bf Ab0$ `\bf Ab0`                  |$\sf Ab0$ `\sf Ab0`              |
|$\rm Ab0$ `\rm Ab0`                  |$\bold{Ab0}$ `\bold{Ab0}`            |$\mathsfit{Ab0}$ `\mathsfit{Ab0}`|
|$\textnormal{Ab0}$ `\textnormal{Ab0}`|$\boldsymbol{Ab0}$ `\boldsymbol{Ab0}`|$\Bbb{AB}$ `\Bbb{AB}`            |
|$\text{Ab0}$ `\text{Ab0}`            |$\bm{Ab0}$ `\bm{Ab0}`                |$\mathbb{AB}$ `\mathbb{AB}`      |
|$\textup{Ab0}$ `\textup{Ab0}`        |$\textmd{Ab0}$ `\textmd{Ab0}`        |$\frak{Ab0}$ `\frak{Ab0}`        |
|$\mathit{Ab0}$ `\mathit{Ab0}`        |$\mathtt{Ab0}$ `\mathtt{Ab0}`        |$\mathfrak{Ab0}$ `\mathfrak{Ab0}`|
|$\textit{Ab0}$ `\textit{Ab0}`        |$\texttt{Ab0}$ `\texttt{Ab0}`        |$\mathcal{AB0}$ `\mathcal{AB0}`  |
|$\it Ab0$ `\it Ab0`                  |$\tt Ab0$ `\tt Ab0`                  |$\cal AB0$ `\cal AB0`            |
|$\emph{Ab0}$ `\emph{Ab0}`            |                                     |$\mathscr{AB}$ `\mathscr{AB}`    |

使用字体函数的 `\textXX` 版本，可以将字体族、字重和字形叠加在一起。例如 `\textsf{\textbf{H}}` 会得到 $\textsf{\textbf{H}}$。其他版本则无法叠加，例如 `\mathsf{\mathbf{H}}` 只会得到 $\mathsf{\mathbf{H}}$。

当 KaTeX 字体中没有某个粗体字形时，可以用 `\pmb` 来模拟。例如 `\pmb{\mu}` 会渲染为：$\pmb{\mu}$

**大小**

|||
|:----------------------|:-----
|$\Huge AB$ `\Huge AB`  |$\normalsize AB$ `\normalsize AB`
|$\huge AB$ `\huge AB`  |$\small AB$ `\small AB`
|$\LARGE AB$ `\LARGE AB`|$\footnotesize AB$ `\footnotesize AB`
|$\Large AB$ `\Large AB`|$\scriptsize AB$ `\scriptsize AB`
|$\large AB$ `\large AB`|$\tiny AB$ `\tiny AB`

**样式**

||
|:-------------------------------------------------------|
|$\displaystyle\sum_{i=1}^n$ `\displaystyle\sum_{i=1}^n`
|$\textstyle\sum_{i=1}^n$ `\textstyle\sum_{i=1}^n`
|$\scriptstyle x$ `\scriptstyle x` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;（第一级上下标的大小）
|$\scriptscriptstyle x$ `\scriptscriptstyle x`（更深层级上下标的大小）
|$\lim\limits_x$ `\lim\limits_x`
|$\lim\nolimits_x$ `\lim\nolimits_x`
|$\verb!x^2!$ `\verb!x^2!`

`\text{…}` 可以接受嵌套的 `$…$` 片段，并将其渲染为数学模式。

## 符号与标点

||||
|:----------|:----------|:----------|
|`% comment`|$\dots$ `\dots`|$\KaTeX$ `\KaTeX`
|$\%$ `\%`|$\cdots$ `\cdots`|$\LaTeX$ `\LaTeX`
|$\#$ `\#`|$\ddots$ `\ddots`|$\TeX$ `\TeX`
|$\&$ `\&`|$\ldots$ `\ldots`|$\nabla$ `\nabla`
|$\_$ `\_`|$\vdots$ `\vdots`|$\infty$ `\infty`
|$\text{\textunderscore}$ `\text{\textunderscore}`|$\dotsb$ `\dotsb`|$\infin$ `\infin`
|$\text{--}$ `\text{--}`|$\dotsc$ `\dotsc`|$\checkmark$ `\checkmark`
|$\text{\textendash}$ `\text{\textendash}`|$\dotsi$ `\dotsi`|$\dag$ `\dag`
|$\text{---}$ `\text{---}`|$\dotsm$ `\dotsm`|$\dagger$ `\dagger`
|$\text{\textemdash}$ `\text{\textemdash}`|$\dotso$ `\dotso`|$\text{\textdagger}$ `\text{\textdagger}`
|$\text{\textasciitilde}$ `\text{\textasciitilde}`|$\sdot$ `\sdot`|$\ddag$ `\ddag`
|$\text{\textasciicircum}$ `\text{\textasciicircum}`|$\mathellipsis$ `\mathellipsis`|$\ddagger$ `\ddagger`
|$`$ <code>`</code>|$\text{\textellipsis}$ `\text{\textellipsis}`|$\text{\textdaggerdbl}$ `\text{\textdaggerdbl}`
|$\text{\textquoteleft}$ `\text{\textquoteleft}`|$\Box$ `\Box`|$\Dagger$ `\Dagger`
|$\lq$ `\lq`|$\square$ `\square`|$\angle$ `\angle`
|$\text{\textquoteright}$ `\text{\textquoteright}`|$\blacksquare$ `\blacksquare`|$\measuredangle$ `\measuredangle`
|$\rq$ `\rq`|$\triangle$ `\triangle`|$\sphericalangle$ `\sphericalangle`
|$\text{\textquotedblleft}$ `\text{\textquotedblleft}`|$\triangledown$ `\triangledown`|$\top$ `\top`
|$"$ `"`|$\triangleleft$ `\triangleleft`|$\bot$ `\bot`
|$\text{\textquotedblright}$ `\text{\textquotedblright}`|$\triangleright$ `\triangleright`|$\$$ `\$`
|$\colon$ `\colon`|$\bigtriangledown$ `\bigtriangledown`|$\text{\textdollar}$ `\text{\textdollar}`
|$\backprime$ `\backprime`|$\bigtriangleup$ `\bigtriangleup`|$\pounds$ `\pounds`
|$\prime$ `\prime`|$\blacktriangle$ `\blacktriangle`|$\mathsterling$ `\mathsterling`
|$\text{\textless}$ `\text{\textless}`|$\blacktriangledown$ `\blacktriangledown`|$\text{\textsterling}$ `\text{\textsterling}`
|$\text{\textgreater}$ `\text{\textgreater}`|$\blacktriangleleft$ `\blacktriangleleft`|$\yen$ `\yen`
|$\text{\textbar}$ `\text{\textbar}`|$\blacktriangleright$ `\blacktriangleright`|$\surd$ `\surd`
|$\text{\textbardbl}$ `\text{\textbardbl}`|$\diamond$ `\diamond`|$\degree$ `\degree`
|$\text{\textbraceleft}$ `\text{\textbraceleft}`|$\Diamond$ `\Diamond`|$\text{\textdegree}$ `\text{\textdegree}`
|$\text{\textbraceright}$ `\text{\textbraceright}`|$\lozenge$ `\lozenge`|$\mho$ `\mho`
|$\text{\textbackslash}$ `\text{\textbackslash}`|$\blacklozenge$ `\blacklozenge`|$\diagdown$ `\diagdown`
|$\text{\P}$ `\text{\P}` 或 `\P`|$\star$ `\star`|$\diagup$ `\diagup`
|$\text{\S}$ `\text{\S}` 或 `\S`|$\bigstar$ `\bigstar`|$\flat$ `\flat`
|$\text{\sect}$ `\text{\sect}`|$\clubsuit$ `\clubsuit`|$\natural$ `\natural`
|$\copyright$ `\copyright`|$\clubs$ `\clubs`|$\sharp$ `\sharp`
|$\circledR$ `\circledR`|$\diamondsuit$ `\diamondsuit`|$\heartsuit$ `\heartsuit`
|$\text{\textregistered}$ `\text{\textregistered}`|$\diamonds$ `\diamonds`|$\hearts$ `\hearts`
|$\circledS$ `\circledS`|$\spadesuit$ `\spadesuit`|$\spades$ `\spades`
|$\text{\textcircled a}$ `\text{\textcircled a}`|$\maltese$ `\maltese`|$\minuso$ `\minuso`|

直接输入：§ ¶ $ £ ¥ ∇ ∞ · ∠ ∡ ∢ ♠ ♡ ♢ ♣ ♭ ♮ ♯ ✓ …  ⋮  ⋯  ⋱  !$ ‼ ⦵

## 单位

在 KaTeX 中，单位的比例关系与 TeX 中一致。<br>
KaTeX 单位与 CSS 单位不同。


|  KaTeX 单位 | 数值       | KaTeX 单位  | 数值  |
|:---|:---------------------|:---|:----------------|
| em | CSS em               | bp | 1/72 英寸 × F × G|
| ex | CSS ex               | pc | 12 KaTeX pt|
| mu | 1/18 CSS em          | dd | 1238/1157 KaTeX pt  |
| pt | 1/72.27 英寸 × F × G | cc | 14856/1157 KaTeX pt |
| mm | 1 mm × F × G         | nd | 685/642 KaTeX pt |
| cm | 1 cm × F × G         | nc | 1370/107 KaTeX pt|
| in | 1 英寸 × F × G       | sp | 1/65536 KaTeX pt |


其中：

$$
F = （周围 HTML 文本的字体大小）/(10 pt)
$$

G 默认为 1.21，因为 KaTeX 的字体大小通常是周围字体大小的 1.21 倍。该值可以[被覆盖](font.md#font-size-and-lengths)，通过 HTML 页面的 CSS 来实现。


样式与大小对单位的影响：


|  单位  |     textstyle     | scriptscript |  huge  |
|:------:|:-----------------:|:------------:|:------:|
|em 或 ex|$\rule{1em}{1em}$  |$\scriptscriptstyle\rule{1em}{1em}$  |$\huge\rule{1em}{1em}$
| mu     |$\rule{18mu}{18mu}$|$\scriptscriptstyle\rule{18mu}{18mu}$|$\huge\rule{18mu}{18mu}$
| 其他 |$\rule{10pt}{10pt}$|$\scriptscriptstyle\rule{10pt}{10pt}$|$\huge\rule{10pt}{10pt}$