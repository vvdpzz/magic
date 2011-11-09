# encoding: utf-8

User.create(
  [
    {
      name: '薛晓东',
      email: 'xxd@gmail.com',
      password: 'xxdxxd'
    },
    {
      name: '陈政宇',
      email: 'vvdpzz@gmail.com',
      password: 'vvdpzz'
    },
    {
      name: '黄飞平',
      email: 'feipinghuang@gmail.com',
      password: 'feiping'
    },
    {
      name: '李园园',
      email: 'windstill@gmail.com',
      password: 'windstill'
    },
    {
      name: '陈浩',
      email: 'chrishyman256@gmail.com',
      password: 'chrishyman'
    }
  ]
)

user = User.first

user.questions.create(
  [
    {
      title: "Ultra simplistic and minimally styled pagination inspired by Rdio"
    },
    {
      title: "Breadcrumb navigation is used as a way to show users where they are within an app or a site"
    },
    {
      title: "Put the shorthand form within the tag and set a title for the complete name"
    },
    {
      title: "What are the most creative euphemisms for layoffs?"
    },
    {
      title: "What are all of the hidden emoticons on HipChat?"
    }
  ]
)