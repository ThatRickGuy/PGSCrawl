using OpenQA.Selenium;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Remote;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Windows;
using PGSwiss.Data;

namespace PGSCrawl
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            System.Net.WebClient wc = new System.Net.WebClient();
            string webData = wc.DownloadString("http://ringdev.com/swiss/standings/default.aspx");

            var links = new List<string>();
            var linkChunks = webData.Split(new string[] { "<a href=" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var linkChunk in linkChunks)
                if (linkChunk.Contains(".html"))
                    links.Add("http://ringdev.com/swiss/standings/" + linkChunk.Split(new string[] { "." }, StringSplitOptions.RemoveEmptyEntries)[0].Remove(0, 1) + ".xml");

            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder
            {
                //builder.DataSource = "trgguidtest.database.windows.net,1433";
                DataSource = "tcp:s11.winhost.com",
                //builder.UserID = "thatrickguy";
                UserID = "DB_98488_ringdev_user",
                //builder.Password = "Sulton24!";
                Password = "Sulton24!",

                InitialCatalog = "DB_98488_ringdev"
            };
            using (SqlConnection conn = new SqlConnection(builder.ConnectionString))
            {
                conn.Open();
                
                string exists = "IF EXISTS(SELECT * FROM PGSCrawl WITH (UPDLOCK) WHERE GameID=@GameID) ";

                string insert = "INSERT INTO PGSCrawl( EventID,  EventDate,  RoundNumber,  GameID, Condition,  Scenario,  Length, " +
                                                    "WinnerCCCode, WinnerMeta, WinnerFaction, WinnerTheme1, WinnerTheme2, WinnerCaster1, WinnerCaster2, WinnerCP, WinnerAPD," +
                                                    "OpponentCCCode, OpponentMeta, OpponentFaction, OpponentTheme1, OpponentTheme2, OpponentCaster1, OpponentCaster2, OpponentCP, OpponentAPD" +
                                                    ") values " +
                                                    "(@EventID, @EventDate, @RoundNumber, @GameID, @Condition,@Scenario, @Length," +
                                                    "@WinnerCCCode,@WinnerMeta,@WinnerFaction,@WinnerTheme1,@WinnerTheme2,@WinnerCaster1,@WinnerCaster2,@WinnerCP,@WinnerAPD," +
                                                    "@OpponentCCCode,@OpponentMeta,@OpponentFaction,@OpponentTheme1,@OpponentTheme2,@OpponentCaster1,@OpponentCaster2,@OpponentCP,@OpponentAPD" +
                                                    ") ";

                string update = "UPDATE PGSCrawl SET WinnerCCCode=@WinnerCCCode, WinnerMeta=@WinnerMeta, WinnerFaction=@WinnerFaction, " +
                                                    "WinnerTheme1=@WinnerTheme1, WinnerTheme2=@WinnerTheme2, WinnerCaster1=@WinnerCaster1, WinnerCaster2=@WinnerCaster2, " +
                                                    "WinnerCP=@WinnerCP, WinnerAPD=@WinnerAPD," +
                                                    "OpponentCCCode=@OpponentCCCode, OpponentMeta=@OpponentMeta, OpponentFaction=@OpponentFaction, " +
                                                    "OpponentTheme1=@OpponentTheme1, OpponentTheme2=@OpponentTheme2, OpponentCaster1=@OpponentCaster1, OpponentCaster2=@OpponentCaster2, " +
                                                    "OpponentCP=@OpponentCP, OpponentAPD=@OpponentAPD " +
                                "WHERE GAMEID=@GameID ";

                var FullQuery = exists + update + " ELSE " + insert;

                if (File.Exists("output.csv"))
                    File.Delete("output.csv");
                File.WriteAllText("output.csv", "Event Date,Game ID,Winner,Condition,Scenario,Length,Faction,CP,APD,Opponent Faction,Opponent CP,Opponent APD");
                foreach (var link in links)
                {
                    try
                    {
                        webData = wc.DownloadString(link);

                        File.WriteAllText("temp.xml", webData);
                        var wmevent = new doWMEvent("temp.xml");

                        if ("2017 Steam Roller, 2018 Masters, 2018 Steamroller, 2018 Champions, 2017 Steamroller, 2017 Masters, 2017 Champions".Contains(wmevent.EventFormat.Name)
                            && wmevent.EventID.ToString() != "2a8107d1-3bfd-4df7-a031-a9468c630ba3"
                            && wmevent.EventID.ToString() != "e3448557-62cb-4f71-942a-2f65a1297e44"
                            && wmevent.EventID.ToString() != "dde7460c-c544-48d6-b19f-da9d8be33e18"
                            && wmevent.EventID.ToString() != "8fcbbd7c-b394-477f-af05-d795fd59bd0f"
                            && wmevent.EventID.ToString() != "9187622e-66bc-4255-96d1-37682aa01f9e"
                            && !wmevent.Name.ToLower().Contains("shadespire")
                            )
                        {
                            if (wmevent.Rounds.Count > 2 && wmevent.Rounds[2].Games.Count > 0)
                                foreach (var rnd in wmevent.Rounds)
                                    foreach (var game in rnd.Games)
                                    {
                                        //&& is shortcutting, if Player2 is null, Player2.Name is not accessed. 
                                        if (game.Player2 != null &&
                                            game.Player2.Name != "Bye")
                                        {
                                            using (SqlCommand command = new SqlCommand(FullQuery, conn))
                                            {
                                                doPlayer Winner;
                                                doPlayer Opponent;

                                                if (game.Winner == game.Player1.Name)
                                                {
                                                    Winner = game.Player1;
                                                    Opponent = game.Player2;
                                                }
                                                else
                                                {
                                                    Winner = game.Player2;
                                                    Opponent = game.Player1;
                                                }

                                                command.Parameters.Add("@EventID", SqlDbType.VarChar).Value = wmevent.EventID.ToString();
                                                command.Parameters.Add("@EventDate", SqlDbType.Date).Value = wmevent.EventDate;
                                                command.Parameters.Add("@RoundNumber", SqlDbType.SmallInt).Value = rnd.RoundNumber;
                                                command.Parameters.Add("@GameID", SqlDbType.VarChar).Value = game.GameID.ToString();
                                                command.Parameters.Add("@Condition", SqlDbType.VarChar).Value = game.Condition ?? "";
                                                command.Parameters.Add("@Scenario", SqlDbType.VarChar).Value = game.Scenario ?? "";
                                                command.Parameters.Add("@Length", SqlDbType.TinyInt).Value = game.GameLength ?? 0;

                                                command.Parameters.Add("@WinnerFaction", SqlDbType.VarChar).Value = Winner.Faction ?? "";
                                                command.Parameters.Add("@WinnerCCCode", SqlDbType.VarChar).Value = "" + Winner.CCCode;
                                                command.Parameters.Add("@WinnerMeta", SqlDbType.VarChar).Value = "" + Winner.Meta;
                                                command.Parameters.Add("@WinnerTheme1", SqlDbType.VarChar).Value = "" + Winner.Theme1;
                                                command.Parameters.Add("@WinnerTheme2", SqlDbType.VarChar).Value = "" + Winner.Theme2;
                                                command.Parameters.Add("@WinnerCaster1", SqlDbType.VarChar).Value = "" + Winner.Caster1;
                                                command.Parameters.Add("@WinnerCaster2", SqlDbType.VarChar).Value = "" + Winner.Caster2;
                                                command.Parameters.Add("@WinnerCP", SqlDbType.VarChar).Value = Winner.ControlPoints;
                                                command.Parameters.Add("@WinnerAPD", SqlDbType.TinyInt).Value = Winner.ArmyPointsDestroyed;

                                                if (Opponent != null)
                                                {
                                                    command.Parameters.Add("@OpponentFaction", SqlDbType.VarChar).Value = Opponent.Faction ?? "";
                                                    command.Parameters.Add("@OpponentCCCode", SqlDbType.VarChar).Value = "" + Opponent.CCCode;
                                                    command.Parameters.Add("@OpponentMeta", SqlDbType.VarChar).Value = "" + Opponent.Meta;
                                                    command.Parameters.Add("@OpponentTheme1", SqlDbType.VarChar).Value = "" + Opponent.Theme1;
                                                    command.Parameters.Add("@OpponentTheme2", SqlDbType.VarChar).Value = "" + Opponent.Theme2;
                                                    command.Parameters.Add("@OpponentCaster1", SqlDbType.VarChar).Value = "" + Opponent.Caster1;
                                                    command.Parameters.Add("@OpponentCaster2", SqlDbType.VarChar).Value = "" + Opponent.Caster2;
                                                    command.Parameters.Add("@OpponentCP", SqlDbType.VarChar).Value = Opponent.ControlPoints;
                                                    command.Parameters.Add("@OpponentAPD", SqlDbType.TinyInt).Value = Opponent.ArmyPointsDestroyed;
                                                }
                                                else
                                                {
                                                    //Shouldn't happen
                                                    command.Parameters.Add("@OpponentFaction", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentCCCode", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentMeta", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentTheme1", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentTheme2", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentCaster1", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentCaster2", SqlDbType.VarChar).Value = "";
                                                    command.Parameters.Add("@OpponentCP", SqlDbType.VarChar).Value = 0;
                                                    command.Parameters.Add("@OpponentAPD", SqlDbType.TinyInt).Value = 0;

                                                }
                                                command.ExecuteNonQuery();
                                            }
                                        }
                                    }
                        }
                        else if ("Other, Highlander".Contains(wmevent.EventFormat.Name))
                        { // known format we don't care about
                        }
                        else
                        {
                            MessageBox.Show("Unknown Format: " + wmevent.EventFormat.Name);
                        }

                    }
                    catch (System.Net.WebException exc)
                    {
                        //xml not found
                    }
                }

            }



        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder
            {
                //builder.DataSource = "trgguidtest.database.windows.net,1433";
                DataSource = "tcp:s11.winhost.com",
                //builder.UserID = "thatrickguy";
                UserID = "DB_98488_ringdev_user",
                //builder.Password = "Sulton24!";
                Password = "Sulton24!"
            };

            var CCCodeToActuals = new Dictionary<string, string>();
            var dCCCode = new Dictionary<string, string>();

            builder.InitialCatalog = "DB_98488_ringdev";
            using (SqlConnection conn = new SqlConnection(builder.ConnectionString))
            {
                var AllCCCodes = new List<string>();
                var sql = "select distinct cccode " +
                          "from " +
                          "(select winnercccode as CCCode from pgscrawl where WinnerCCCode <> '' and winnercaster1 = ''" +
                          "union " +
                          "select OpponentCCCode as CCCode from pgscrawl where OpponentCCCode <> '' and opponentcaster1 = '') tbl1";
                using (SqlCommand command = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    var dr = command.ExecuteReader();
                    while (dr.Read())
                    {
                        AllCCCodes.Add(dr.GetString(0));
                    }
                    dr.Close();
                }

                var i = 0;
                foreach (var CCCode in AllCCCodes)
                {
                    i++;
                    try
                    {
                        //https://api.conflictchamber.com/list/[CCCode].txt

                        // 1-based index of lists
                        //https://api.conflictchamber.com/list/[CCCode]/2/caster
                        //https://api.conflictchamber.com/list/[CCCode]/2/theme

                        string Theme1 = "";
                        using (var wc = new System.Net.WebClient())
                            Theme1 = wc.DownloadString("https://api.conflictchamber.com/list/" + CCCode + "/1/theme");
                        string Caster1 = "";
                        using (var wc = new System.Net.WebClient())
                            Caster1 = wc.DownloadString("https://api.conflictchamber.com/list/" + CCCode + "/1/caster");


                        string Theme2 = "";
                        using (var wc = new System.Net.WebClient())
                            Theme2 = wc.DownloadString("https://api.conflictchamber.com/list/" + CCCode + "/2/theme");
                        string Caster2 = "";
                        using (var wc = new System.Net.WebClient())
                            Caster2 = wc.DownloadString("https://api.conflictchamber.com/list/" + CCCode + "/2/caster");
                        
                        using (SqlCommand update = new SqlCommand("UPDATE PGSCrawl SET WinnerCaster1=@WinnerCaster1, WinnerCaster2=@WinnerCaster2, WinnerTheme1=@WinnerTheme1, WinnerTheme2=@WinnerTheme2 WHERE WinnerCCCode = @CCCode", conn))
                        {
                            update.Parameters.Add("@WinnerCaster1", SqlDbType.VarChar).Value = Caster1 == "Index out of range" ? "" : Caster1;
                            update.Parameters.Add("@WinnerTheme1", SqlDbType.VarChar).Value = Theme1 == "Index out of range" ? "" : Theme1;
                            update.Parameters.Add("@WinnerCaster2", SqlDbType.VarChar).Value = Caster2 == "Index out of range" ? "" : Caster2;
                            update.Parameters.Add("@WinnerTheme2", SqlDbType.VarChar).Value = Theme2 == "Index out of range" ? "" : Theme2;
                            update.Parameters.Add("@CCCode", SqlDbType.VarChar).Value = "" + CCCode;
                            update.ExecuteNonQuery();
                        }

                        using (SqlCommand update = new SqlCommand("UPDATE PGSCrawl SET OpponentCaster1=@OpponentCaster1, OpponentCaster2=@OpponentCaster2, OpponentTheme1=@OpponentTheme1, OpponentTheme2=@OpponentTheme2 WHERE OpponentCCCode = @CCCode", conn))
                        {
                            update.Parameters.Add("@OpponentCaster1", SqlDbType.VarChar).Value = Caster1 == "Index out of range" ? "" : Caster1;
                            update.Parameters.Add("@OpponentTheme1", SqlDbType.VarChar).Value = Theme1 == "Index out of range" ? "" : Theme1;
                            update.Parameters.Add("@OpponentCaster2", SqlDbType.VarChar).Value = Caster2 == "Index out of range" ? "" : Caster2;
                            update.Parameters.Add("@OpponentTheme2", SqlDbType.VarChar).Value = Theme2 == "Index out of range" ? "" : Theme2;
                            update.Parameters.Add("@CCCode", SqlDbType.VarChar).Value = "" + CCCode;
                            update.ExecuteNonQuery();
                        }
                    }
                    catch (Exception exc)
                    {
                        Console.WriteLine(exc.Message);
                    }

                    Console.WriteLine(i + "/" + AllCCCodes.Count );
                }
            }
        }
    }
}


