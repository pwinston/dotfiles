return function(home)
  return {
    default = 'work',
    projects = {
      { type = 'simple', name = 'work', dir = home .. '/kobold', key = '0' },
    },
  }
end
