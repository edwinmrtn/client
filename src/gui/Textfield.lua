local TTextfield = {}
local TTextfieldMetatable = {__index = TTextfield}
TTextfield.Type = "Textfield"
TTextfield.Text = ""
TTextfield.HintText = ""
TTextfield.TextOffset = -2.5
TTextfield.Start = 0
TTextfield.Length = 0
TTextfield.Writeable = true
setmetatable(TTextfield, gui.TGadgetMetatable)

function gui.CreateTextfield(x, y, Width, Height, Parent, HintText)
	local Textfield = TTextfield.New()
	if Parent:AddGadget(Textfield) then
		Textfield:SetPosition(x, y)
		Textfield:SetDimensions(Width, Height)
		return Textfield:Init(HintText)
	end
end

function TTextfield:Send()
end

function TTextfield.New()
	return setmetatable({}, TTextfieldMetatable)
end

function TTextfield:Init(Text)
	self.HintText = Text
	self.Timer = love.timer.getTime()
	return self
end

function TTextfield:SetText(Text)
	self.Text = Text
	if self.Start > #Text then
		self.Start = #Text
	elseif self.Length > 0 then
		if self.Start + self.Length > #Text then
			self.Length = #Text - self.Start
		end
	end
end

function TTextfield:SetFont(Font)
	self.Font = Font
end

function TTextfield:Write(Text)
	if not self.Hidden and not self.Disabled then
		local Length = #Text
		if self.Length == 0 then
			if self.Start == #self.Text then
				self.Text = self.Text .. Text
			elseif self.Start < #self.Text then
				self.Text = self.Text:sub(1, self.Start) .. Text .. self.Text:sub(self.Start + 1)
			end
			self.Start = self.Start + Length
		elseif self.Length > 0 then
			self.Text = self.Text:sub(1, self.Start) .. Text .. self.Text:sub(self.Start + self.Length + 1)
			self.Start = self.Start + Length
			self.Length = 0
		elseif self.Length < 0 then
			self.Text = self.Text:sub(1, self.Start + self.Length) .. Text .. self.Text:sub(self.Start + 1)
			self.Start = self.Start + self.Length + Length
			self.Length = 0
		end

		local TextfieldText = self.Text
		if self.Password then
			TextfieldText = string.rep("*", Length)
		end
		local Font = self:GetFont()
		local Position = Font:getWidth(TextfieldText:sub(1, Start)) + 2.5
		if Position > self:GetWidth() then
			self.TextOffset = Position - self:GetWidth()
		end
	end
end

function TTextfield:keypressed(key)
	if self.Hidden or self.Disabled then
		return nil
	end

	local Text = self.Text
	local Length = #self.Text
	if self.Password then
		Text = string.rep("*", Length)
	end
	local Font = self:GetFont()
	if key == "backspace" then
		if self.Length == 0 then
			local Width = Font:getWidth(Text:sub(self.Start, self.Start))
			if Font:getWidth(Text) - Width > self:GetWidth() then
				self.TextOffset = math.max(self.TextOffset - Width, -2.5)
			else
				self.TextOffset = -2.5
			end
			self.Text = self.Text:sub(1, self.Start - 1) .. self.Text:sub(self.Start + 1)
			self.Start = math.max(self.Start - 1, 0)
		elseif self.Length > 0 then
			self.Text = self.Text:sub(1, self.Start) .. self.Text:sub(self.Start + self.Length + 1)
			self.Length = 0
		else
			self.Text = self.Text:sub(1, self.Start + self.Length) .. self.Text:sub(self.Start + 1)
			self.Start = math.max(self.Start + self.Length, 0)
			self.Length = 0
		end
	elseif key == "delete" then
		if self.Length == 0 then
			self.Text = self.Text:sub(1, self.Start) .. self.Text:sub(self.Start + 1)
		elseif self.Length > 0 then
			self.Text = self.Text:sub(1, self.Start) .. self.Text:sub(self.Start + self.Length + 1)
			self.Length = 0
		else
			self.Text = self.Text:sub(1, self.Start + self.Length) .. self.Text:sub(self.Start + 1)
			self.Start = math.max(self.Start + self.Length, 0)
			self.Length = 0
		end
	elseif key == "left" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.Length = math.max(self.Length - 1, -self.Start)
			if self.Length < 0 then
				local Width = Font:getWidth(Text:sub(1, self.Start + self.Length)) - 2.5
				if Width < self.TextOffset then
					self.TextOffset = Width
				end
			elseif self.Length > 0 then
				local Width = Font:getWidth(Text:sub(1, self.Start)) - 2.5
				if Width < self.TextOffset then
					self.TextOffset = Width
				end
			end
		else
			if self.Length == 0 then
				self.Start = math.max(self.Start - 1, 0)
				self.Length = 0
				local Width = Font:getWidth(Text:sub(1, self.Start)) - 2.5
				if Width < self.TextOffset then
					self.TextOffset = Width
				end
			elseif self.Length > 0 then
				self.Length = 0
				local Width = Font:getWidth(Text:sub(1, self.Start)) - 2.5
				if Width < self.TextOffset then
					self.TextOffset = Width
				end
			else
				self.Start = math.max(self.Start + self.Length, 0)
				self.Length = 0
				local Width = Font:getWidth(Text:sub(1, self.Start)) - 2.5
				if Width < self.TextOffset then
					self.TextOffset = Width
				end
			end
		end
	elseif key == "right" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.Length = math.min(self.Length + 1, Length - self.Start)
			if self.Length > 0 then
				local Width = Font:getWidth(Text:sub(1, self.Start + self.Length)) + 2.5
				if Width > self.TextOffset + self:GetWidth() then
					self.TextOffset = Width - self:GetWidth()
				end
			elseif self.Length < 0 then
				local Width = Font:getWidth(Text:sub(1, self.Start + self.Length)) + 2.5
				if Width > self.TextOffset + self:GetWidth() then
					self.TextOffset = Width - self:GetWidth()
				end
			end
		else
			if self.Length == 0 then
				self.Start = math.max(math.min(self.Start + self.Length + 1, Length), 0)
				self.Length = 0

				local Width = Font:getWidth(Text:sub(1, self.Start)) + 2.5
				if Width > self.TextOffset + self:GetWidth() then
					self.TextOffset = Width - self:GetWidth()
				end
			elseif self.Length > 0 then
				self.Start = math.max(math.min(self.Start + self.Length, Length), 0)
				self.Length = 0
				local Width = Font:getWidth(Text:sub(1, self.Start)) + 2.5
				if Width > self.TextOffset + self:GetWidth() then
					self.TextOffset = Width - self:GetWidth()
				end
			else
				self.Length = 0
				local Width = Font:getWidth(Text:sub(1, self.Start)) + 2.5
				if Width > self.TextOffset + self:GetWidth() then
					self.TextOffset = Width - self:GetWidth()
				end
			end
		end
	elseif key == "home" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.Length = -self.Start
		else
			self.Start = 0
			self.Length = 0
		end
		self.TextOffset = -2.5
	elseif key == "end" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.Length = #Text - self.Start
		else
			self.Start = #Text
			self.Length = 0
		end
		local Width = Font:getWidth(Text)
		if Width > self:GetWidth() then
			self.TextOffset = Width - self:GetWidth() + 2.5
		end
	elseif key == "return" then
		self:Send()
	end
end

function TTextfield:MouseClicked(x, y)
	if self.BaseClass.MouseClicked(self, x, y) then
		local Text = self.Text
		local Length = #self.Text
		if self.Password then
			Text = string.rep("*", Length)
		end
		local SelectPosition = self.Grabbed.x + self.TextOffset
		local TextWidth = 0
		local Font = self:GetFont()
		for i = 1, #self.Text do
			local Width = Font:getWidth(Text:sub(i, i))
			if SelectPosition > TextWidth and SelectPosition <= TextWidth + Width then
				self.Start = i
				self.Length = 0
				TextWidth = TextWidth + Width
				break
			end
			TextWidth = TextWidth + Width
		end
		if SelectPosition > TextWidth then
			self.Start = #self.Text
			self.Length = 0
		elseif SelectPosition <= 0 then
			self.Start = 0
			self.Length = 0
		end
		return true
	end
end

function TTextfield:MouseDropped(x, y)
	if not self.Hidden then
		if self.Grabbed then
			self.Grabbed = nil
			self.Dropped = {x = x - self:x(), y = y - self:y()}
			self:OnDrop(self.Dropped.x, self.Dropped.y)

			local Text = self.Text
			local Length = #self.Text
			if self.Password then
				Text = string.rep("*", Length)
			end
			local SelectPosition = self.Dropped.x + self.TextOffset
			local TextWidth = 0
			local Font = self:GetFont()
			for i = 1, #self.Text do
				local Width = Font:getWidth(Text:sub(i, i))
				if SelectPosition > TextWidth and SelectPosition <= TextWidth + Width then
					self.Length = i - self.Start
					TextWidth = TextWidth + Width
					break
				end
				TextWidth = TextWidth + Width
			end
			if SelectPosition > TextWidth then
				self.Length = #self.Text - self.Start
			elseif SelectPosition <= 0 then
				self.Length = -self.Start
			end
		end
	end
end

function TTextfield:MouseMove(x, y, dx, dy)
	if not self.Hidden then
		if self.Grabbed then
			local Text = self.Text
			local Length = #self.Text
			if self.Password then
				Text = string.rep("*", Length)
			end
			local SelectPosition = x - self:x() + self.TextOffset
			local TextWidth = 0
			local Font = self:GetFont()
			for i = 1, #self.Text do
				local Width = Font:getWidth(Text:sub(i, i))
				if SelectPosition > TextWidth and SelectPosition <= TextWidth + Width then
					self.Length = i - self.Start
					TextWidth = TextWidth + Width
					break
				end
				TextWidth = TextWidth + Width
			end
			if SelectPosition > TextWidth then
				self.Length = #self.Text - self.Start
			elseif SelectPosition <= 0 then
				self.Length = -self.Start
			end
		end
	end
end

function TTextfield:Copy()
	if not self.Hidden then
		if not self.Password then
			if self.Length > 0 then
				return self.Text:sub(self.Start + 1, self.Start + self.Length)
			elseif self.Length < 0 then
				return self.Text:sub(self.Start + self.Length + 1, self.Start)
			end
		end
	end
end

function TTextfield:Update(dt)
	if not self.Hidden and not self.Disabled then
		if self.Grabbed then
			local x = love.mouse.getX() - self:x()
			local Width = self:GetWidth()
			if x < -2.5 then
				self.TextOffset = math.max(self.TextOffset + x * dt / 170, -2.5)
			elseif x > Width + 2.5 then
				local Text = self.Text
				local Length = #self.Text
				if self.Password then
					Text = string.rep("*", Length)
				end
				local Font = self:GetFont()
				local TextWidth = Font:getWidth(Text)
				if TextWidth > Width then
					x = x - Width
					self.TextOffset = math.min(self.TextOffset + x * dt / 170, Font:getWidth(Text) - Width + 2.5)
				end
			end
		end
	end
end

function TTextfield:Render(dt)
	if not self.Hidden then
		local x, y = self:GetPosition()
		local Width, Height = self:GetDimensions()
		local Theme = self:GetTheme()
		local Font = self:GetFont()
		local TextY = (Height - Font:getHeight())/2
		local First = self:IsFirst()

		love.graphics.setScissor(x - 1, y - 1, Width + 2, Height + 2)
		love.graphics.setColor(unpack(Theme.Border))
		love.graphics.rectangle("line", x, y, Width, Height)

		love.graphics.setColor(unpack(Theme.Background))
		love.graphics.rectangle("fill", x, y, Width, Height)

		local Text = self.Text
		local Length = #self.Text
		if self.Password then
			Text = string.rep("*", Length)
		end
		love.graphics.setScissor(x, y, Width, Height)
		love.graphics.setFont(Font)
		if #self.Text > 0 or First then
			love.graphics.setColor(unpack(Theme.Text))
			love.graphics.print(Text, x - self.TextOffset, y + TextY)
		else
			love.graphics.setColor(unpack(Theme.HintText))
			love.graphics.print(self.HintText, x + 2.5, y + TextY)
		end

		if not self.Disabled and First then
			if love.timer.getTime() - self.Timer > 0.5 then
				self.Tick = not self.Tick
				self.Timer = love.timer.getTime()
			end
		elseif self.Tick then
			self.Tick = nil
		end

		if self.Length == 0 then
			if self.Tick then
				love.graphics.print("|", x + Font:getWidth(Text:sub(1, self.Start)) - self.TextOffset - 2, y + TextY)
			end
		else
			love.graphics.setColor(unpack(Theme.SelectedText))
			if self.Length > 0 then
				love.graphics.rectangle("fill", x + Font:getWidth(Text:sub(1, self.Start)) - self.TextOffset, y + TextY, Font:getWidth(Text:sub(self.Start + 1, self.Start + self.Length)), Font:getHeight())
			else
				love.graphics.rectangle("fill", x + Font:getWidth(Text:sub(1, self.Start + self.Length)) - self.TextOffset, y + TextY, Font:getWidth(Text:sub(self.Start + self.Length + 1, self.Start)), Font:getHeight())
			end
		end
		self:RenderGadgets(dt)
	end
end
