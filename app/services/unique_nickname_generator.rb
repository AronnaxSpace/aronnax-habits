class UniqueNicknameGenerator
  def self.generate(base_nickname)
    nickname = base_nickname
    suffix = 1

    while Profile.exists?(nickname: nickname)
      nickname = "#{base_nickname}#{suffix}"
      suffix += 1
    end

    nickname
  end
end
