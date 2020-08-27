using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace GetODPDeltaToken
{
    public static class GetODPDeltaToken
    {
        // This is the class that will be deserialized.
        [XmlRoot(ElementName = "feed", Namespace = "http://www.w3.org/2005/Atom")]
        public class Feed
        {
            [XmlElement(ElementName = "id")]
            public string id;
            [XmlElement(ElementName = "title")]
            public string title;
            [XmlElement(ElementName = "updated")]
            public string updated;
            [XmlElement(ElementName = "author")]
            public Author author;
            [XmlElement(ElementName = "link")]
            public string link;
            [XmlElement(ElementName = "entry")]
            public Entry[] entries;
        }

        public class Author
        {
            public string name;
        }

        public class Entry
        {
            public string id;
            public string title;
            public string updated;
            public Content content;
        }

        public class Content
        {
            [XmlAttribute(AttributeName = "type")]
            public string contentType;
            [XmlElement(ElementName = "properties", Namespace = "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata")]
            public DeltaLink deltaLink;
        }

        public class DeltaLink : IComparable<DeltaLink>
        {
            [XmlElement(ElementName = "DeltaToken", Namespace = "http://schemas.microsoft.com/ado/2007/08/dataservices")]
            public string deltaToken;
            [XmlElement(ElementName = "CreatedAt", Namespace = "http://schemas.microsoft.com/ado/2007/08/dataservices")]
            public DateTime createdAt;
            [XmlElement(ElementName = "IsInitialLoad", Namespace = "http://schemas.microsoft.com/ado/2007/08/dataservices")]
            public string isInitialLoad;

            public int CompareTo(DeltaLink deltaLink)
            {
                return -1 * createdAt.CompareTo(deltaLink.createdAt);
            }
        }




        [FunctionName("GetODPDeltaToken")]
        public static async Task<JObject> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("GetODPDeltaToken -  HTTP trigger function received a request.");

            HttpClient client = new HttpClient();

            //TODO : Is this Base Address Needed?
            client.BaseAddress = new Uri("http://x.x.x.x:50000/sap/opu/odata/SAP/ZBDL_ODP_ODATA_SRV/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(
                new MediaTypeWithQualityHeaderValue("application/xml"));
            
            //Insert User Id and password here
            var byteArray = Encoding.ASCII.GetBytes("userid:password");
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", Convert.ToBase64String(byteArray));

            var TARGETURL = "http://x.x.x.x:50000/sap/opu/odata/SAP/ZBDL_ODP_ODATA_SRV/DeltaLinksOfAttrOfZBD_ISALESDOC_1";

            Feed feed = null;
            log.LogInformation("Calling URL ...");
            HttpResponseMessage response = await client.GetAsync(TARGETURL);
            log.LogInformation("... URL Called");

            if (response.IsSuccessStatusCode)
            {
                //subscription = await response.Content.ReadAsAsync<SubscribedToAttrOfZBD_ISALESDOC_1>(); -- this does not take the XmlRoot & XmlElement into account
                XmlSerializer serializer = new XmlSerializer(typeof(Feed));

                using (Stream reader = await response.Content.ReadAsStreamAsync())
                {
                    // Call the Deserialize method to restore the object's state.
                    feed = (Feed)serializer.Deserialize(reader);
                }

            }

            log.LogInformation("Id : " + feed.id);
            log.LogInformation("Title : " + feed.title);
            log.LogInformation("Updated : " + feed.updated);
            log.LogInformation("Author/Name : " + feed.author.name);
            log.LogInformation("link : " + feed.link);

            List<DeltaLink> deltaLinkList = new List<DeltaLink>();

            foreach (Entry entry in feed.entries)
            {
                // Write out the properties of the object.
                log.LogInformation("entry/id : " + entry.id);
                log.LogInformation("entry/title : " + entry.title);
                log.LogInformation("entry/updated : " + entry.updated);
                log.LogInformation("entry/category/content/type : " + entry.content.contentType);
                log.LogInformation("entry/category/content/properties/DeltaToken : " + entry.content.deltaLink.deltaToken);
                log.LogInformation("entry/category/content/properties/CreatedAt : " + entry.content.deltaLink.createdAt);
                log.LogInformation("entry/category/content/properties/IsInitialLoad : " + entry.content.deltaLink.isInitialLoad);
                deltaLinkList.Add(entry.content.deltaLink);
            }

            log.LogInformation("Writing Delta Links - Original");
            foreach (var deltaLink in deltaLinkList)
            {
                log.LogInformation("... DeltaToken : " + deltaLink.deltaToken);
                log.LogInformation("... CreatedAt : " + deltaLink.createdAt);
                log.LogInformation("... IsInitialLoad : " + deltaLink.isInitialLoad);
            }

            deltaLinkList.Sort();
            log.LogInformation("Writing Delta Links - Sorted");
            foreach (var deltaLink in deltaLinkList)
            {
                log.LogInformation("... DeltaToken : " + deltaLink.deltaToken);
                log.LogInformation("... CreatedAt : " + deltaLink.createdAt);
                log.LogInformation("... IsInitialLoad : " + deltaLink.isInitialLoad);
            }

            var maxDeltaToken = deltaLinkList[0];
            log.LogInformation("Retrieved DeltaToken : " + maxDeltaToken.deltaToken);

            JObject output = new JObject(new JProperty("DeltaToken", maxDeltaToken.deltaToken));
            log.LogInformation("GetODPDeltaToken - HTTP trigger function processed a request.");

            return output;
        }
    }
}
