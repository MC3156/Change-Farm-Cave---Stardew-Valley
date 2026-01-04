<#
  Copyright (c) 2026 MC3156&Dreamy_Blaze
  This source code is licensed under the MIT license found in the
  LICENSE file in the root directory of this source tree.
#>

Add-Type -AssemblyName System.Windows.Forms
# [System.Windows.Forms.MessageBox]::Show("Debug: ", "")

# 主函数
function main {
	Write-Host $Global:waitPlease -ForegroundColor Yellow
	if ((checkFile) -eq 0) {
		noticePrompt $Global:errorTitle $Global:errorInvalidSave $Global:btnClose $true
		return
	}
	$caveBat = $Global:content.Indexof("<caveChoice>1</caveChoice>")
	$caveMushroom = $Global:content.Indexof("<caveChoice>2</caveChoice>")
	$caveNone = $Global:content.Indexof("<caveChoice>0</caveChoice>")
	if ($caveNone -gt -1) {
		noticePrompt $Global:errorTitle $Global:errorUnchosen $Global:btnClose $true
	} elseif ($caveBat -gt -1) {
		Write-Host $Global:waitSelection -ForegroundColor Yellow
		if ((confirmPrompt $Global:title ($Global:currentCave + $Global:bat + "`n" + $Global:infoConfirm + $Global:mushroom + $Global:questionMark) $Global:yes $Global:no $true) -eq 1) {
			Write-Host $Global:waitProcessing -ForegroundColor Yellow
			$Global:content = $Global:content.Replace("<caveChoice>1</caveChoice>", "<caveChoice>2</caveChoice>")
			$result = ReplaceBetween $Global:content "<GameLocation xsi:type=`"FarmCave`">" "</GameLocation>" "<objects>" "</objects>" "<objects />" $true
			if ($result.Success) {
				$Global:content = $result.Text
			}
			$result = ProcessTextContent $Global:content "<GameLocation xsi:type=`"FarmCave`">" $Global:nullStr "<objects />" $Global:nullStr $Global:nullStr $Global:mushroomObjects
			if ($result.Success) {
				$Global:content = $result.Text
			} else {
				noticePrompt $Global:errorTitle $Global:processingFailed $Global:btnClose $true
				return
			}
			modifyFile $Global:saveFile $Global:content
			noticePrompt $Global:okTitle $Global:infoChanged $Global:btnClose
		}
	} elseif ($caveMushroom -gt -1) {
		Write-Host $Global:waitSelection -ForegroundColor Yellow
		if ((confirmPrompt $Global:title ($Global:currentCave + $Global:mushroom + "`n" + $Global:infoConfirm + $Global:bat + $Global:questionMark) $Global:yes $Global:no $true) -eq 1) {
			Write-Host $Global:waitProcessing -ForegroundColor Yellow
			$Global:content = $Global:content.Replace("<caveChoice>2</caveChoice>", "<caveChoice>1</caveChoice>")
			$result = ReplaceBetween $Global:content "<GameLocation xsi:type=`"FarmCave`">" "</GameLocation>" "<objects>" "</objects>" "<objects />" $true
			if ($result.Success) {
				$Global:content = $result.Text
			}
			modifyFile $Global:saveFile $Global:content
			noticePrompt $Global:okTitle $Global:infoChanged $Global:btnClose
		}
	} else {
		noticePrompt $Global:errorTitle $Global:notSupportedType $Global:btnClose $true
	}
}
# 函数-检查存档有效性，更新全局变量(文本和文件路径)
function checkFile {
	$checkFile1 = "SaveGameInfo"
	if (-not (Test-Path $checkFile1)) {
		return 0
	}
	$content = Get-Content $checkFile1 -Encoding UTF8 -Raw
	$index1 = $content.IndexOf("</Farmer>")
	if ($index1 -lt 0) {
		return 0
	}
	Get-ChildItem -File | Where-Object {
		$_.BaseName -match '^.+_\d+$' -and $_.Extension -eq ''
	} | ForEach-Object {
		$checkFile2 = $_.FullName
		$content = Get-Content $checkFile2 -Encoding UTF8 -Raw
		$index2 = $content.IndexOf("</SaveGame>")
		if ($index2 -ge 0) {
			$count++
			$Global:saveFile = $checkFile2
			$Global:content = $content
			return 1
		}
	}
	return 0
}
# 函数-备份写入存档文件
function modifyFile {
	param([string]$filePath, [string]$content)
	$backup   = "$filePath.bak"
	Copy-Item -Path $filePath -Destination $backup -Force
	$writer = [System.IO.StreamWriter]::new($filePath, $false, [System.Text.Encoding]::UTF8)
	$writer.write($content)
	$writer.Close()
}
# 函数-通知提示框
function noticePrompt {
	param([string]$title, [string]$content, [string]$button, [bool]$hasSound = $false)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(350,180)
	$form.StartPosition = "CenterScreen"
	$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$label = New-Object System.Windows.Forms.Label
	$label.Text = $content
	$label.AutoSize = $true
	$label.Location = New-Object System.Drawing.Point(25,25)
	$label.Font = New-Object System.Drawing.Font($label.Font.FontFamily, 12)
	$label.MaximumSize = New-Object System.Drawing.Size(300,0)
	$form.Controls.Add($label)
	$btnOK = New-Object System.Windows.Forms.Button
	$btnOK.Text = $button
	$btnOK.Size = New-Object System.Drawing.Size(80,35)
	$btnOK.Location = New-Object System.Drawing.Point(125,90)
	$btnOK.Add_Click({ $form.Close() })
	$form.Controls.Add($btnOK)
	if ($hasSound) { [System.Media.SystemSounds]::Asterisk.Play() }
	$form.ShowDialog()
}
# 函数-选择提示框
function confirmPrompt {
	param([string]$title, [string]$content, [string]$confirmButton, [string]$cancelButton, [bool]$hasSound = $false)
	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(350,180)
	$form.StartPosition = "CenterScreen"
	$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$label = New-Object System.Windows.Forms.Label
	$label.Text = $content
	$label.AutoSize = $true
	$label.Location = New-Object System.Drawing.Point(25,25)
	$label.Font = New-Object System.Drawing.Font($label.Font.FontFamily, 12)
	$label.MaximumSize = New-Object System.Drawing.Size(300,0)
	$form.Controls.Add($label)
	$btnConfirm = New-Object System.Windows.Forms.Button
	$btnConfirm.Text = $confirmButton
	$btnConfirm.Size = New-Object System.Drawing.Size(80,35)
	$btnConfirm.Location = New-Object System.Drawing.Point(70,90)
	$btnConfirm.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.Controls.Add($btnConfirm)
	$btnCancel = New-Object System.Windows.Forms.Button
	$btnCancel.Text = $cancelButton
	$btnCancel.Size = New-Object System.Drawing.Size(80,35)
	$btnCancel.Location = New-Object System.Drawing.Point(180,90)
	$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.Controls.Add($btnCancel)
	$form.AcceptButton = $btnConfirm
	$form.CancelButton = $btnCancel
	if ($hasSound) { [System.Media.SystemSounds]::Asterisk.Play() }
	$result = $form.ShowDialog()
	if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
		return 1
	} else {
		return 0
	}
}
# 函数-简单替换标记文本
function ReplaceBetween {
	param(
		[string]$Text, # 原字符串
		[string]$AnchorText = "", # 检查起点
		[string]$StopText = "", # 检查终点
		[string]$StartMarker, # 开始标记
		[string]$EndMarker, # 结束标记
		[string]$Replacement, # 替换开始与结束标记之间的文本
		[bool]$IncludeMarkers = $false # 是否包含标记一起替换
		# 返回结构化对象数组，元素1是文本，元素2是成功与否
	)
	$searchStartPos = 0
	if ($AnchorText -and $AnchorText.Length -gt 0) {
		$anchorPos = $Text.IndexOf($AnchorText)
		if ($anchorPos -lt 0) {
			return [PSCustomObject]@{ Text = $Text; Success = $false }
		}
		$searchStartPos = $anchorPos + $AnchorText.Length
	} else {
		$searchStartPos = 0
	}
	$startPos = $Text.IndexOf($StartMarker, $searchStartPos)
	if ($startPos -lt 0) {
		return [PSCustomObject]@{ Text = $Text; Success = $false }
	}
	if ($StopText -and $StopText.Length -gt 0) {
		$stopPos = $Text.IndexOf($StopText, $searchStartPos)
		if ($stopPos -ge 0 -and $stopPos -lt $startPos) {
			return [PSCustomObject]@{ Text = $Text; Success = $false }
		}
	}
	$endPos = $Text.IndexOf($EndMarker, $startPos + $StartMarker.Length)
	if ($endPos -lt 0) {
		return [PSCustomObject]@{ Text = $Text; Success = $false }
	}
	if ($IncludeMarkers) {
		$beforeText = $Text.Substring(0, $startPos)
		$afterText = $Text.Substring($endPos + $EndMarker.Length)
		$newText = $beforeText + $Replacement + $afterText
	} else {
		$beforeText = $Text.Substring(0, $startPos + $StartMarker.Length)
		$afterText = $Text.Substring($endPos)
		$newText = $beforeText + $Replacement + $afterText
	}
	return [PSCustomObject]@{ Text = $newText; Success = $true }
}
# 函数-多功能XML文本处理函数
function ProcessTextContent {
	param(
		[string]$FileContent, # 原字符串
		[string]$StartText, # 检查起点
		[string]$TargetText1, # 测试文本1-若先检查到，则在此位置后插入文本InsertText
		[string]$TargetText2, # 测试文本2-若先检查到，则使用文本ReplaceText替换该文本
		[string]$TargetText3, # 测试文本3-若先检查到或未检查到任何测试文本，输出DefaultText
		[string]$InsertText,
		[string]$ReplaceText,
		[string]$DefaultText = "Error???" # 处理失败的输出，现已禁用
		# 返回结构化对象数组，元素1是文本，元素2是成功与否
	)
	$startPos = $FileContent.IndexOf($StartText, [System.StringComparison]::OrdinalIgnoreCase)
	if ($startPos -lt 0) {
		return [PSCustomObject]@{ Text = $FileContent; Success = $false }
	}
	$searchStart = $startPos + $StartText.Length
	$pos1 = $FileContent.IndexOf($TargetText1, $searchStart, [System.StringComparison]::OrdinalIgnoreCase)
	$pos2 = $FileContent.IndexOf($TargetText2, $searchStart, [System.StringComparison]::OrdinalIgnoreCase)
	$pos3 = $FileContent.IndexOf($TargetText3, $searchStart, [System.StringComparison]::OrdinalIgnoreCase)
	$targets = @(
		[PSCustomObject]@{ Type = 1; Pos = $pos1 }
		[PSCustomObject]@{ Type = 2; Pos = $pos2 }
		[PSCustomObject]@{ Type = 3; Pos = $pos3 }
	) | Where-Object { $_.Pos -ge 0 } | Sort-Object Pos | Select-Object -First 1
	if (-not $targets) {
		return [PSCustomObject]@{ Text = $FileContent; Success = $false }
	}
	$type = $targets.Type
	$pos  = $targets.Pos
	switch ($type) {
		1 {
			$insertPos = $pos + $TargetText1.Length
			$newText =
				$FileContent.Substring(0, $insertPos) +
				$InsertText +
				$FileContent.Substring($insertPos)
			return [PSCustomObject]@{ Text = $newText; Success = $true }
		}
		2 {
			$newText =
				$FileContent.Substring(0, $pos) +
				$ReplaceText +
				$FileContent.Substring($pos + $TargetText2.Length)
			return [PSCustomObject]@{ Text = $newText; Success = $true }
		}
		Default {
			return [PSCustomObject]@{ Text = $FileContent; Success = $false }
		}
	}
}
# 语言/Language
$lang = [System.Globalization.CultureInfo]::CurrentUICulture.Name
if ($lang -like "zh*") {
	$Global:waitPlease = "扫描存档中，请稍等 ~ ~ ~"
	$Global:waitSelection = "等待用户选择中..."
	$Global:waitProcessing = "存档处理中..."
	$Global:btnClose = "关闭"
	$Global:errorInvalidSave = "原因：未找到有效的存档文件"
	$Global:errorTitle = "更改农场洞穴 - 错误 ×"
	$Global:errorUnchosen = "原因：你还没有选择农场洞穴"
	$Global:currentCave = "当前农场洞穴："
	$Global:bat = "蝙蝠"
	$Global:mushroom = "蘑菇"
	$Global:yes = "是"
	$Global:no = "否"
	$Global:infoConfirm = "是否更改为"
	$Global:questionMark = "？"
	$Global:title = "更改农场洞穴"
	$Global:notSupportedType = "当前类型不受支持"
	$Global:okTitle = "更改农场洞穴 - 完成 OvO"
	$Global:infoChanged = "好，操作完成！"
	$Global:processingFailed = "处理失败，未知错误"
} else {
	$Global:waitPlease = "Scanning the game save, please wait a moment ~ ~ ~"
	$Global:waitSelection = "Waiting for user selection..."
	$Global:waitProcessing = "Processing..."
	$Global:btnClose = "Close"
	$Global:errorInvalidSave = "Reason: No valid game save file found"
	$Global:errorTitle = "ChangeFarmCave - Error ×"
	$Global:errorUnchosen = "Reason: You haven't chosen the farm cave yet"
	$Global:currentCave = "Current Farm Cave: "
	$Global:bat = "Bat"
	$Global:mushroom = "Mushroom"
	$Global:yes = "Yes"
	$Global:no = "No"
	$Global:infoConfirm = "Do you want to change it to "
	$Global:questionMark = "?"
	$Global:title = "ChangeFarmCave"
	$Global:notSupportedType = "The current type is not supported"
	$Global:okTitle = "ChangeFarmCave - Completed OvO"
	$Global:infoChanged = "Bingo, operation completed!"
	$Global:processingFailed = "Processing failed, unknown error"
}
# 全局变量
$Global:saveFile
$Global:content
$Global:nullStr = "@null@"
$Global:mushroomObjects = "<objects><item><key><Vector2><X>4</X><Y>5</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>4</X><Y>5</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>256</X><Y>320</Y><Width>64</Width><Height>64</Height><Location><X>256</X><Y>320</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>6</X><Y>5</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>6</X><Y>5</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>384</X><Y>320</Y><Width>64</Width><Height>64</Height><Location><X>384</X><Y>320</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>8</X><Y>5</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>8</X><Y>5</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>512</X><Y>320</Y><Width>64</Width><Height>64</Height><Location><X>512</X><Y>320</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>4</X><Y>7</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>4</X><Y>7</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>256</X><Y>448</Y><Width>64</Width><Height>64</Height><Location><X>256</X><Y>448</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>6</X><Y>7</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>6</X><Y>7</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>384</X><Y>448</Y><Width>64</Width><Height>64</Height><Location><X>384</X><Y>448</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>8</X><Y>7</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Mushroom Box</name><parentSheetIndex>128</parentSheetIndex><itemId>128</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>8</X><Y>7</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>2</fragility><price>0</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><heldObject><isLostItem>false</isLostItem><category>-81</category><hasBeenInInventory>false</hasBeenInInventory><name>Common Mushroom</name><parentSheetIndex>404</parentSheetIndex><itemId>404</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>0</X><Y>0</Y></tileLocation><owner>0</owner><type>Basic</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>40</price><edibility>15</edibility><bigCraftable>false</bigCraftable><setOutdoors>false</setOutdoors><setIndoors>false</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>true</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>0</X><Y>0</Y><Width>0</Width><Height>0</Height><Location><X>0</X><Y>0</Y></Location><Size><X>0</X><Y>0</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></heldObject><lastOutputRuleId>Default</lastOutputRuleId><minutesUntilReady>1600</minutesUntilReady><boundingBox><X>512</X><Y>448</Y><Width>64</Width><Height>64</Height><Location><X>512</X><Y>448</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>5</X><Y>6.9999957</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item><item><key><Vector2><X>10</X><Y>5</Y></Vector2></key><value><Object><isLostItem>false</isLostItem><category>-9</category><hasBeenInInventory>false</hasBeenInInventory><name>Dehydrator</name><parentSheetIndex>286</parentSheetIndex><itemId>Dehydrator</itemId><specialItem>false</specialItem><isRecipe>false</isRecipe><quality>0</quality><stack>1</stack><SpecialVariable>0</SpecialVariable><tileLocation><X>10</X><Y>5</Y></tileLocation><owner>0</owner><type>Crafting</type><canBeSetDown>true</canBeSetDown><canBeGrabbed>true</canBeGrabbed><isSpawnedObject>false</isSpawnedObject><questItem>false</questItem><isOn>true</isOn><fragility>0</fragility><price>50</price><edibility>-300</edibility><bigCraftable>true</bigCraftable><setOutdoors>true</setOutdoors><setIndoors>true</setIndoors><readyForHarvest>false</readyForHarvest><showNextIndex>false</showNextIndex><flipped>false</flipped><isLamp>false</isLamp><minutesUntilReady>0</minutesUntilReady><boundingBox><X>640</X><Y>320</Y><Width>64</Width><Height>64</Height><Location><X>640</X><Y>320</Y></Location><Size><X>64</X><Y>64</Y></Size></boundingBox><scale><X>0</X><Y>0</Y></scale><uses>0</uses><destroyOvernight>false</destroyOvernight></Object></value></item></objects>"

main

