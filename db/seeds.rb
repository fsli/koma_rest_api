# This file should contain all the record creation needed to seed the database with its default values.

# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


def seed_koma_user
  KomaUser.create(id: 1, username: 'koma_user1', attr: 1)
  KomaUser.create(id: 2, username: 'koma_user2', attr: 2)
  KomaUser.create(id: 3, username: 'koma_user3', attr: 3)
  sql = "SELECT setval('koma_users_id_seq', (SELECT max(id) FROM koma_users));"
  ActiveRecord::Base.connection.execute(sql)
end

def seed_koma
  Koma.create(owner_id: 1, koma_date: DateTime.strptime("03/01/2016 9:00", "%m/%d/%Y %H:%M"), koma_type: 1, prospect_name: "prospect_name1", memo: "some memo text1")
  Koma.create(owner_id: 2, koma_date: DateTime.strptime("03/02/2016 9:00", "%m/%d/%Y %H:%M"), koma_type: 2, prospect_name: "prospect_name2", memo: "some memo text2")
  Koma.create(owner_id: 3, koma_date: DateTime.strptime("03/03/2016 9:00", "%m/%d/%Y %H:%M"), koma_type: 3, prospect_name: "prospect_name3", memo: "some memo text3")
end
seed_koma_user()
seed_koma()