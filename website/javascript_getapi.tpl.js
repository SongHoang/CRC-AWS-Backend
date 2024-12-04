const apiBaseUrl = "${api_url}/Default";

async function grabData() {
  try {
    const response = await fetch('apiBaseUrl');
    if (!response.ok) {
      //throw new Error(`HTTP error! status: response.status`);
    }
    const data = await response.json();
    const count = await data.Attributes.Visitors;
    const myVariable = data.Attributes.Visitors; // Replace 'someProperty' with the key you need
    //console.log('Variable from API:', myVariable);
    //console.log('Type of the variable', typeof myVariable);
    //document.getElementById("id01").innerHTML = myVariable;
    console.log('Variable returned', count);
    return count;

  } catch (error) {
    console.error('There was a problem with the fetch operation:', error);
  }
}

async function getCount(){

  const visitorCount = await grabData();

  //const var1 = await data.Attributes;
  console.log('Type of the variable:', typeof visitorCount);
  console.log('Variable from API, ', visitorCount);
  document.getElementById("id01").innerHTML = visitorCount;

}


